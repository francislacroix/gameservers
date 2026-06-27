using './main.bicep'

param vnetName = 'gameservers-vnet'
param vnetAddressPrefix = '10.0.0.0/16'

param containerAppsSubnetName = 'gameservers-cae-snet'
param containerAppsSubnetPrefix = '10.0.0.0/24'

param containerRegistryName = 'lacroixgameservers'
param acrServicePrincipalObjectId = ''

param storageAccountName = 'lacroixgameservers'

param containerAppsEnvironmentName = 'gameservers-cae'
