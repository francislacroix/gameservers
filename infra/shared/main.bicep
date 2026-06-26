// Bicep file for deploying the game server infrastructure.
// This file defines the resources shared by all game servers.
targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location


// Virtual Network Parameters
@description('Name of the virtual network.')
param vnetName string = 'gameservers-vnet'

@description('Address space for the virtual network.')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet used by the Container Apps Environment infrastructure.')
param containerAppsSubnetName string = 'gameservers-cae-snet'

@description('Address prefix for the Container Apps subnet.')
param containerAppsSubnetPrefix string = '10.0.0.0/24'

// Container Registry Parameters
@description('Container Registry name.')
param containerRegistryName string = 'lacroixgameservers'

// Container Apps Environment Parameters
@description('Container Apps Environment name.')
param containerAppsEnvironmentName string = 'gameservers-cae'

// Step 1: Create the Virtual Network and subnets
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource containerAppsSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: containerAppsSubnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: containerAppsSubnetPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.ContainerRegistry'
      }
    ]
    delegations: [
      {
        name: 'container-apps-delegation'
        properties: {
          serviceName: 'Microsoft.App/environments'
        }
      }
    ]
  }
}

//Step 2: Create the Azure Container Registry and its private endpoint
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'None'
    networkRuleSet: any({
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: containerAppsSubnet.id
          action: 'Allow'
        }
      ]
    })
  }
}

// Step 4: Create the Container Apps Environment
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: containerAppsEnvironmentName
  location: location
  properties: {
    vnetConfiguration: {
      infrastructureSubnetId: containerAppsSubnet.id
      internal: false
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
output containerAppsSubnetId string = containerAppsSubnet.id
output containerAppsEnvironmentId string = containerAppsEnvironment.id
