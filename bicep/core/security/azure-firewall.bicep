// azure-firewall.bicep
// Standalone Azure Firewall module with Premium policy, IDPS, application and network
// rule collections, DNS proxy, and threat intelligence. Use this module when you need
// a firewall deployed outside the hub-vnet module (e.g. existing VNet scenarios).

targetScope = 'resourceGroup'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Name of the Azure Firewall')
param firewallName string = 'afw-001'

@description('Resource ID of the AzureFirewallSubnet')
param firewallSubnetId string

@description('Firewall SKU tier')
@allowed([
  'Standard'
  'Premium'
])
param skuTier string = 'Premium'

@description('Enable IDPS in Alert and Deny mode (Premium only)')
param enableIdps bool = true

@description('Tags to apply to all resources')
param tags object = {}

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

var firewallPolicyName = 'afwp-${firewallName}'
var publicIpName = 'pip-${firewallName}'

// ---------------------------------------------------------------------------
// Public IP for the firewall
// ---------------------------------------------------------------------------

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// ---------------------------------------------------------------------------
// Firewall Policy with IDPS, DNS proxy, and threat intelligence
// ---------------------------------------------------------------------------

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-09-01' = {
  name: firewallPolicyName
  location: location
  tags: tags
  properties: {
    sku: {
      tier: skuTier
    }
    threatIntelMode: 'Alert'
    intrusionDetection: (skuTier == 'Premium' && enableIdps) ? {
      mode: 'Deny'
      configuration: {
        signatureOverrides: []
        bypassTrafficSettings: []
      }
    } : null
    dnsSettings: {
      enableProxy: true
    }
  }
}

// ---------------------------------------------------------------------------
// Application Rule Collection Group
// ---------------------------------------------------------------------------

resource appRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' = {
  parent: firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowCommonServices'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'AllowMicrosoftUpdates'
            protocols: [
              { protocolType: 'Https'; port: 443 }
              { protocolType: 'Http'; port: 80 }
            ]
            targetFqdns: [
              '*.microsoft.com'
              '*.windowsupdate.com'
              '*.update.microsoft.com'
              '*.download.windowsupdate.com'
            ]
            sourceAddresses: [ '*' ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AllowAzureManagement'
            protocols: [
              { protocolType: 'Https'; port: 443 }
            ]
            targetFqdns: [
              'management.azure.com'
              'login.microsoftonline.com'
              'graph.microsoft.com'
              '*.azure-automation.net'
              '*.ods.opinsights.azure.com'
              '*.oms.opinsights.azure.com'
            ]
            sourceAddresses: [ '*' ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AllowUbuntuAptUpdates'
            protocols: [
              { protocolType: 'Https'; port: 443 }
              { protocolType: 'Http'; port: 80 }
            ]
            targetFqdns: [
              '*.ubuntu.com'
              '*.canonical.com'
              'packages.microsoft.com'
            ]
            sourceAddresses: [ '*' ]
          }
        ]
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Network Rule Collection Group
// ---------------------------------------------------------------------------

resource networkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-09-01' = {
  parent: firewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  dependsOn: [
    appRuleCollectionGroup
  ]
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowInternalTraffic'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AllowDns'
            ipProtocols: [ 'UDP'; 'TCP' ]
            sourceAddresses: [ '10.0.0.0/8' ]
            destinationAddresses: [ '*' ]
            destinationPorts: [ '53' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'AllowNtp'
            ipProtocols: [ 'UDP' ]
            sourceAddresses: [ '10.0.0.0/8' ]
            destinationAddresses: [ '*' ]
            destinationPorts: [ '123' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'AllowInternalRfc1918'
            ipProtocols: [ 'Any' ]
            sourceAddresses: [ '10.0.0.0/8' ]
            destinationAddresses: [
              '10.0.0.0/8'
              '172.16.0.0/12'
              '192.168.0.0/16'
            ]
            destinationPorts: [ '*' ]
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowAzureKms'
        priority: 110
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AllowKmsActivation'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: [ '10.0.0.0/8' ]
            destinationAddresses: [ '23.102.135.246' ]
            destinationPorts: [ '1688' ]
          }
        ]
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Azure Firewall
// ---------------------------------------------------------------------------

resource firewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: firewallName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: skuTier
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: firewallSubnetId
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
  dependsOn: [
    appRuleCollectionGroup
    networkRuleCollectionGroup
  ]
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output firewallId string = firewall.id
output firewallPolicyId string = firewallPolicy.id
output privateIpAddress string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
