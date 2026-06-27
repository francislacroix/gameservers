using '../../infra/gameserver/main.bicep'

param storageAccountName = '' // Will be provided via pipeline variable, since this is a shared resource across multiple game servers

param fileShareConfigs = [
	{
		shareName: 'dragonwilds-savedcontent'
		shareQuotaGiB: 10
		environmentVolumeName: 'dragonwilds-savedcontent'
		containerVolumeName: 'dragonwilds-savedcontent'
		containerMountPath: '/opt/dragonwildsserver/RSDragonwilds/Saved'
	}
]

param containerAppName = 'gameservers-dragonwilds'
param containerAppsEnvironmentId = '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.App/managedEnvironments/gameservers-cae'
param containerImage = 'lacroixgameservers.azurecr.io/dragonwilds:latest'
param command = './RSDragonwildsServer.sh'
param args = [
	'-log'
	'-NewConsole'
	'-Port=7777'
]
param targetPort = 7777
param additionalPortMappings = [7778]
param containerCpu = '3.0'
param containerMemory = '6Gi'
