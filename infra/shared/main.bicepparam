using './main.bicep'

param vnetName = 'gameservers-vnet'
param vnetAddressPrefix = '10.0.0.0/16'

param privateEndpointsSubnetName = 'gameservers-pe-snet'
param privateEndpointsSubnetPrefix = '10.0.0.0/24'

param containerAppsSubnetName = 'gameservers-cae-snet'
param containerAppsSubnetPrefix = '10.0.1.0/24'

param containerAppsEnvironmentName = 'gameservers-cae'
