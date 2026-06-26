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

@description('Subnet used for private endpoints.')
param privateEndpointsSubnetName string = 'gameservers-pe-snet'

@description('Address prefix for the private endpoints subnet.')
param privateEndpointsSubnetPrefix string = '10.0.0.0/24'

@description('Subnet used by the Container Apps Environment infrastructure.')
param containerAppsSubnetName string = 'gameservers-cae-snet'

@description('Address prefix for the Container Apps subnet.')
param containerAppsSubnetPrefix string = '10.0.1.0/24'

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

resource privateEndpointsSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: privateEndpointsSubnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: privateEndpointsSubnetPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource containerAppsSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: containerAppsSubnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: containerAppsSubnetPrefix
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
    publicNetworkAccess: 'Disabled'
  }
}

resource containerRegistryPrivateEndpoint 'Microsoft.Network/privateEndpoints@2025-07-01' = {
  name: '${containerRegistryName}-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${containerRegistryName}-plc'
        properties: {
          privateLinkServiceId: containerRegistry.id
          groupIds: [
            'registry'
          ]
        }
      }
    ]
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
output privateEndpointsSubnetId string = privateEndpointsSubnet.id
output containerAppsSubnetId string = containerAppsSubnet.id
output containerAppsEnvironmentId string = containerAppsEnvironment.id
