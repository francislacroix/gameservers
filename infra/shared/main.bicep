// Bicep file for deploying the shared game server infrastructure.
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

@description('Object ID of the GitHub Federated Service Principal to assign ACR Push and Pull roles.')
param gitHubServicePrincipalObjectId string

@description('Name of the user-assigned managed identity for pulling images from the container registry in container apps.')
param imagePullIdentityName string

// Storage Parameters
@description('Storage account name for persisted data. Must be globally unique and lowercase (3-24 chars).')
@minLength(3)
@maxLength(24)
param storageAccountName string = toLower('gameservers${uniqueString(resourceGroup().id)}')

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
      {
        service: 'Microsoft.Storage'
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

//Step 2: Create the Azure Container Registry and provide the necessary permissions
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

// AcrPush: 8311e382-0749-4cb8-b61a-304f252e45ec
resource acrPushRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, gitHubServicePrincipalObjectId, '8311e382-0749-4cb8-b61a-304f252e45ec')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec')
    principalId: gitHubServicePrincipalObjectId
    principalType: 'ServicePrincipal'
  }
}

// Create a user assigned managed identity for the container apps to pull images from the container registry
resource imagePullIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: imagePullIdentityName
  location: location
}

// AcrPull: 7f951dda-4ed3-4680-a7ca-43fe172d538d
resource containerAppPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, imagePullIdentity.id, 'acrpull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: imagePullIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Step 3: Create the Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'PremiumV2_LRS'
  }
  kind: 'FileStorage'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: containerAppsSubnet.id
          action: 'Allow'
        }
      ]
      ipRules: []
      defaultAction: 'Deny'
    }
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2025-08-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: false
    }
    protocolSettings: {
      smb: {
        encryptionInTransit: {
          required: true
        }
      }
      nfs: {
        encryptionInTransit: {
          required: true
        }
       
      }
    }
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
