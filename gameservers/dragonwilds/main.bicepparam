using '../../infra/gameserver/main.bicep'

param storageAccountName = '' // Will be provided via pipeline variable

param fileShareConfigs = [
	{
		shareName: 'dragonwilds-savedcontent'
		shareQuotaGiB: 32
		environmentVolumeName: 'dragonwilds-savedcontent'
		containerVolumeName: 'dragonwilds-savedcontent'
		containerMountPath: '/opt/dragonwildsserver/RSDragonwilds/Saved'
	}
]

param containerAppName = 'dragonwilds'
param containerAppsEnvironmentName = '' 		// Will be provided via pipeline variable
param containerRegistry = ''								// Will be provided via pipeline variable
param containerImage = 'dragonwilds:1'
param imagePullIdentityName = '' 						// Will be provided via pipeline variable
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
