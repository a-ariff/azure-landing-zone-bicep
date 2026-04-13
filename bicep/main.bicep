// main.bicep
// Azure Landing Zone orchestrator - deploys resource groups and calls all modules
// in the correct order with dependency chains.

targetScope = 'subscription'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string

@description('Azure region for all resources')
param location string

@description('Resource name prefix')
param prefix string

@description('Tags to apply to all resources')
param tags object = {}

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

var envSuffix = environment
var networkingRgName = 'rg-${prefix}-networking-${envSuffix}'
var securityRgName = 'rg-${prefix}-security-${envSuffix}'
var monitoringRgName = 'rg-${prefix}-monitoring-${envSuffix}'

var hubVnetName = 'vnet-hub-${prefix}-${envSuffix}'
var keyVaultName = 'kv-${replace(prefix, '-', '')}${envSuffix}'
var logAnalyticsName = 'law-${prefix}-${envSuffix}'

// ---------------------------------------------------------------------------
// Resource Groups
// ---------------------------------------------------------------------------

resource networkingRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: networkingRgName
  location: location
  tags: tags
}

resource securityRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: securityRgName
  location: location
  tags: tags
}

resource monitoringRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: monitoringRgName
  location: location
  tags: tags
}

// ---------------------------------------------------------------------------
// Monitoring (deployed first - other modules depend on workspace ID)
// ---------------------------------------------------------------------------

module logAnalytics 'core/monitoring/log-analytics.bicep' = {
  name: 'deploy-log-analytics'
  scope: monitoringRg
  params: {
    location: location
    workspaceName: logAnalyticsName
    retentionInDays: environment == 'prod' ? 90 : 30
    deploySentinel: environment == 'prod'
    deployVmInsights: true
    tags: tags
  }
}

// ---------------------------------------------------------------------------
// Networking (depends on Log Analytics for diagnostics)
// ---------------------------------------------------------------------------

module hubVnet 'core/networking/hub-vnet.bicep' = {
  name: 'deploy-hub-vnet'
  scope: networkingRg
  params: {
    location: location
    hubVnetName: hubVnetName
    deployAzureFirewall: true
    deployVpnGateway: environment == 'prod'
    deployBastion: true
    tags: tags
  }
  dependsOn: [
    logAnalytics
  ]
}

// ---------------------------------------------------------------------------
// Security (depends on Log Analytics for diagnostics)
// ---------------------------------------------------------------------------

module keyVault 'core/security/key-vault.bicep' = {
  name: 'deploy-key-vault'
  scope: securityRg
  params: {
    location: location
    keyVaultName: keyVaultName
    skuName: environment == 'prod' ? 'premium' : 'standard'
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    enablePurgeProtection: environment == 'prod'
    tags: tags
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output networkingResourceGroupName string = networkingRg.name
output securityResourceGroupName string = securityRg.name
output monitoringResourceGroupName string = monitoringRg.name
output hubVnetId string = hubVnet.outputs.hubVnetId
output hubVnetName string = hubVnet.outputs.hubVnetName
output keyVaultId string = keyVault.outputs.keyVaultId
output keyVaultUri string = keyVault.outputs.keyVaultUri
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output logAnalyticsCustomerId string = logAnalytics.outputs.customerId
