// hub-vnet.bicep
// Deploys hub virtual network with Azure Firewall, VPN Gateway, and Azure Bastion
// Part of the Azure Landing Zone - Hub and Spoke network topology

targetScope = 'resourceGroup'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Name of the hub virtual network')
param hubVnetName string = 'vnet-hub-001'

@description('Address space for the hub VNet')
param hubVnetAddressPrefix string = '10.0.0.0/16'

@description('Address prefix for AzureFirewallSubnet (minimum /26)')
param azureFirewallSubnetPrefix string = '10.0.1.0/26'

@description('Address prefix for GatewaySubnet (minimum /27)')
param gatewaySubnetPrefix string = '10.0.2.0/27'

@description('Address prefix for AzureBastionSubnet (minimum /26)')
param azureBastionSubnetPrefix string = '10.0.3.0/26'

@description('Address prefix for the management subnet')
param managementSubnetPrefix string = '10.0.4.0/24'

@description('Enable Azure Firewall deployment')
param deployAzureFirewall bool = true

@description('Enable VPN Gateway deployment')
param deployVpnGateway bool = true

@description('Enable Azure Bastion deployment')
param deployBastion bool = true

@description('Tags to apply to all resources')
param tags object = {}

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

var firewallName = 'afw-${hubVnetName}'
var firewallPolicyName = 'afwp-${hubVnetName}'
var firewallPublicIpName = 'pip-${firewallName}'
var vpnGatewayName = 'vpngw-${hubVnetName}'
var vpnGatewayPublicIpName = 'pip-${vpnGatewayName}'
var bastionName = 'bas-${hubVnetName}'
var bastionPublicIpName = 'pip-${bastionName}'

// ---------------------------------------------------------------------------
// Hub Virtual Network
// ---------------------------------------------------------------------------

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: hubVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: azureFirewallSubnetPrefix
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: azureBastionSubnetPrefix
        }
      }
      {
        name: 'ManagementSubnet'
        properties: {
          addressPrefix: managementSubnetPrefix
          networkSecurityGroup: {
            id: managementNsg.id
          }
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// NSG for management subnet
// ---------------------------------------------------------------------------

resource managementNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-management-${hubVnetName}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowBastionInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: azureBastionSubnetPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Azure Firewall
// ---------------------------------------------------------------------------

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (deployAzureFirewall) {
  name: firewallPublicIpName
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

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-09-01' = if (deployAzureFirewall) {
  name: firewallPolicyName
  location: location
  tags: tags
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
    dnsSettings: {
      enableProxy: true
    }
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-09-01' = if (deployAzureFirewall) {
  name: firewallName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: hubVnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// VPN Gateway
// ---------------------------------------------------------------------------

resource vpnGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (deployVpnGateway) {
  name: vpnGatewayPublicIpName
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

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = if (deployVpnGateway) {
  name: vpnGatewayName
  location: location
  tags: tags
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    sku: {
      name: 'VpnGw2AZ'
      tier: 'VpnGw2AZ'
    }
    activeActive: false
    enableBgp: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: hubVnet.properties.subnets[1].id
          }
          publicIPAddress: {
            id: vpnGatewayPublicIp.id
          }
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Azure Bastion
// ---------------------------------------------------------------------------

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (deployBastion) {
  name: bastionPublicIpName
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

resource bastion 'Microsoft.Network/bastionHosts@2023-09-01' = if (deployBastion) {
  name: bastionName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    enableTunneling: true
    enableFileCopy: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: hubVnet.properties.subnets[2].id
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output hubVnetId string = hubVnet.id
output hubVnetName string = hubVnet.name
output azureFirewallPrivateIp string = deployAzureFirewall ? firewall.properties.ipConfigurations[0].properties.privateIPAddress : ''
output vpnGatewayId string = deployVpnGateway ? vpnGateway.id : ''
