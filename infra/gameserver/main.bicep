// Bicep file for deploying the game server.
// This file defines the resources and configuration for a specific game server.
targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

// Parameters for the game persistent storage
param storageAccountName string

type fileShareConfig = {
  @description('Azure Files share name for persisted game data.')
  shareName: string

  @description('Quota for the Azure File Share in GiB.')
  @minValue(1)
  shareQuotaGiB: int

  @description('Name of the Azure Container Apps storage volume.')
  environmentVolumeName: string

  @description('Name of the volume inside the container.')
  containerVolumeName: string

   @description('Mount path for the volume inside the container.')
  containerMountPath: string
}

@description('Array of file share configurations for persisted game data.')
param fileShareConfigs fileShareConfig[]

// Parameters for the game server Container App
@description('Name of the Container App for the game server.')
param containerAppName string

@description('Name of the Container Apps Environment where the game server will be deployed.')
param containerAppsEnvironmentName string

@description('Container registry server where the image for the game server is stored.')
param containerRegistry string

@description('Fully qualified container image for the game server.')
param containerImage string

@description('Name of the user-assigned managed identity for pulling images from the container registry.')
param imagePullIdentityName string

@description('Command to run inside the container.')
param command string

@description('Arguments for the command inside the container.')
param args array

@description('Port on which the game server will listen for incoming connections.')
param targetPort int

@description('Additional port mappings for the game server (if any).')
param additionalPortMappings array = []

@description('CPU allocation for the container (e.g., "0.5").')
param containerCpu string

@description('Memory allocation for the container (e.g., "1Gi").')
param containerMemory string

// Step 1: Create Azure File Shares for persisted game data
resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' existing = {
  name: storageAccountName
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2026-04-01' existing = {
  name: 'default'
  parent: storageAccount
}

resource nfsFileShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2026-04-01' = [
  for config in fileShareConfigs: {
    name: config.shareName
    parent: fileService
    properties: {
      provisionedIops: 3000
      provisionedBandwidthMibps: 100
      shareQuota: config.shareQuotaGiB
      enabledProtocols: 'NFS'
      rootSquash: 'NoRootSquash'
    }
  }
]

// Step 2: Create the Volume in the Container Apps Environment for each file share
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2026-01-01' existing = {
  name: containerAppsEnvironmentName
}

resource environmentStorages 'Microsoft.App/managedEnvironments/storages@2026-01-01' = [
  for config in fileShareConfigs: {
    name: config.environmentVolumeName
    parent: containerAppsEnvironment
    properties: {
      nfsAzureFile: {
        accessMode: 'ReadWrite'
        server: split(replace(storageAccount.properties.primaryEndpoints.file, 'https://', ''), '/')[0]
        shareName: '/${storageAccount.name}/${config.shareName}'
      }
    }

    dependsOn: [
      nfsFileShares
    ]
  }
]

// Step 3: Create the Container App for the game server
resource imagePullIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: imagePullIdentityName
  location: location
}
resource containerApp 'Microsoft.App/containerApps@2026-01-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${imagePullIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      registries: [
        {
          server: containerRegistry
          identity: imagePullIdentity.id
        }
      ]
      ingress: {
        external: true
        transport: 'tcp'
        targetPort: targetPort
        exposedPort: targetPort
        additionalPortMappings: [
          for portNumber in additionalPortMappings: {
            external: true
            targetPort: portNumber
            exposedPort: portNumber
          }
        ]
      }
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: '${containerRegistry}/${containerImage}'
          command: [
            command
          ]
          args: args
          resources: {
            cpu: json(containerCpu)
            memory: containerMemory
          }
          volumeMounts: [
            for config in fileShareConfigs: {
              volumeName: config.containerVolumeName
              mountPath: config.containerMountPath
            }
          ]
        }
      ]
      volumes: [
        for config in fileShareConfigs: {
          name: config.containerVolumeName
          storageType: 'NfsAzureFile'
          storageName: config.environmentVolumeName
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }

  dependsOn: [
    environmentStorages
  ]
}
