// Storage Parameters
@description('Storage account name for save data. Must be globally unique and lowercase (3-24 chars).')
@minLength(3)
@maxLength(24)
param storageAccountName string = toLower('stgdragon${uniqueString(resourceGroup().id)}')

@description('Azure Files share name for save game data.')
param fileShareName string = 'savegames'

@description('Quota for the Azure File Share in GiB.')
@minValue(1)
param fileShareQuotaGiB int = 100

resource fileShare 'Microsoft.FileShares/fileShares@2026-06-01' = {
  name: fileShareName
  location: location
  properties: {
    mountName: 'testmount'
    protocol: 'NFS'
    provisionedStorageGiB: 32
    provisionedIOPerSec: 3032
    provisionedThroughputMiBPerSec: 104
    publicAccessProperties: {
      allowedSubnets: []
    }
    redundancy: 'Local'
    mediaTier: 'SSD'
    nfsProtocolProperties: {
      rootSquash: 'NoRootSquash'
      encryptionInTransitRequired: 'Enabled'
    }
    publicNetworkAccess: 'Disabled'
  }
  tags: {}
}

resource environmentStorage 'Microsoft.App/managedEnvironments/storages@2024-10-02-preview' = {
  name: saveVolumeName
  parent: containerAppsEnvironment
  properties: {
    azureFile: {
      accountName: storageAccount.name
      accountKey: storageAccount.listKeys().keys[0].value
      accessMode: 'ReadWrite'
      shareName: saveGameFileShare.name
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2025-01-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: null
      secrets: hasRegistryCredentials ? [
        {
          name: 'acr-password'
          value: registryPassword
        }
      ] : []
      registries: hasRegistryCredentials ? [
        {
          server: registryServer
          username: registryUsername
          passwordSecretRef: 'acr-password'
        }
      ] : []
    }
    template: {
      containers: [
        {
          name: 'dragonwilds'
          image: containerImage
          command: [
            './RSDragonwildsServer.sh'
          ]
          args: [
            '-log'
            '-NewConsole'
            '-Port=7777'
          ]
          resources: {
            cpu: json(containerCpu)
            memory: containerMemory
          }
          volumeMounts: [
            {
              volumeName: saveVolumeName
              mountPath: saveMountPath
            }
          ]
        }
      ]
      volumes: [
        {
          name: saveVolumeName
          storageType: 'AzureFile'
          storageName: environmentStorage.name
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
