using './main.bicep'

param vnetName = 'gameservers-vnet'
param vnetAddressPrefix = '10.0.0.0/16'

param privateEndpointsSubnetName = 'gameservers-pe-snet'
param privateEndpointsSubnetPrefix = '10.0.0.0/24'

param containerAppsSubnetName = 'gameservers-cae-snet'
param containerAppsSubnetPrefix = '10.0.1.0/24'

param storageAccountName = 'gameserversstorage'
param fileShareName = 'savedcontent'
param fileShareQuotaGiB = 100

param containerAppsEnvironmentName = 'gameservers-cae'
param containerAppName = 'gameservers-app'

param containerCpu = '2.0'
param containerMemory = '4Gi'

// Set these only if your container image registry requires credentials.
param registryServer = 'lacroixgameservers.azurecr.io'
param registryUsername = ''
param registryPassword = ''
