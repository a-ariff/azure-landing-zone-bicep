// vwan.bicep
// Deploys Azure Virtual WAN with a secured virtual hub, VPN Gateway, and route tables.
//
// WHEN TO USE vWAN vs TRADITIONAL HUB-AND-SPOKE:
//   - vWAN: Large-scale branch connectivity (>30 sites), global transit routing,
//           any-to-any connectivity required, Microsoft-managed hub routing.
//   - Traditional hub-and-spoke (hub-vnet.bicep): Smaller environments, need full
//           control of hub NVAs, custom routing, cost-sensitive scenarios.
//
// vWAN provides automated spoke-to-spoke routing, built-in SD-WAN integration,
// and a managed hub router. It simplifies operations at the cost of less granular
// control compared to a customer-managed hub VNet.

targetScope = 'resourceGroup'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@description('Azure region for the vWAN resource (metadata only)')
param location string = resourceGroup().location

@description('Name of the Virtual WAN')
param vwanName string = 'vwan-001'

@description('Azure region for the Virtual Hub')
param hubLocation string = location

@description('Address prefix for the Virtual Hub (minimum /23)')
param hubAddressPrefix string = '10.100.0.0/23'

@description('Scale units for the VPN Gateway (1 unit = 500 Mbps)')
@minValue(1)
@maxValue(20)
param vpnGatewayScaleUnit int = 1

@description('Deploy VPN Gateway in the virtual hub')
param deployVpnGateway bool = true

@description('On-premises VPN site public IP address')
param vpnSitePublicIpAddress string = ''

@description('On-premises address prefixes behind the VPN site')
param vpnSiteAddressPrefixes array = []

@description('BGP ASN for the on-premises VPN device')
param vpnSiteBgpAsn int = 65000

@description('BGP peering address on the on-premises VPN device')
param vpnSiteBgpPeeringAddress string = ''

@description('Tags to apply to all resources')
param tags object = {}

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

var virtualHubName = 'vhub-${hubLocation}'
var vpnGatewayName = 'vpngw-${virtualHubName}'
var vpnSiteName = 'vpnsite-onprem-001'
var deployVpnSite = !empty(vpnSitePublicIpAddress)

// ---------------------------------------------------------------------------
// Virtual WAN
// ---------------------------------------------------------------------------

resource vwan 'Microsoft.Network/virtualWans@2023-09-01' = {
  name: vwanName
  location: location
  tags: tags
  properties: {
    type: 'Standard'
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
  }
}

// ---------------------------------------------------------------------------
// Virtual Hub
// ---------------------------------------------------------------------------

resource virtualHub 'Microsoft.Network/virtualHubs@2023-09-01' = {
  name: virtualHubName
  location: hubLocation
  tags: tags
  properties: {
    virtualWan: {
      id: vwan.id
    }
    addressPrefix: hubAddressPrefix
    sku: 'Standard'
  }
}

// ---------------------------------------------------------------------------
// Default route table for the virtual hub
// ---------------------------------------------------------------------------

resource defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2023-09-01' = {
  parent: virtualHub
  name: 'defaultRouteTable'
  properties: {
    labels: [
      'default'
    ]
    routes: []
  }
}

// ---------------------------------------------------------------------------
// VPN Gateway inside the virtual hub
// ---------------------------------------------------------------------------

resource vpnGateway 'Microsoft.Network/vpnGateways@2023-09-01' = if (deployVpnGateway) {
  name: vpnGatewayName
  location: hubLocation
  tags: tags
  properties: {
    virtualHub: {
      id: virtualHub.id
    }
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    bgpSettings: {
      asn: 65515
    }
  }
}

// ---------------------------------------------------------------------------
// VPN Site (on-premises representation)
// ---------------------------------------------------------------------------

resource vpnSite 'Microsoft.Network/vpnSites@2023-09-01' = if (deployVpnSite) {
  name: vpnSiteName
  location: hubLocation
  tags: tags
  properties: {
    virtualWan: {
      id: vwan.id
    }
    ipAddress: vpnSitePublicIpAddress
    addressSpace: {
      addressPrefixes: vpnSiteAddressPrefixes
    }
    bgpProperties: {
      asn: vpnSiteBgpAsn
      bgpPeeringAddress: !empty(vpnSiteBgpPeeringAddress) ? vpnSiteBgpPeeringAddress : '10.0.0.1'
      peerWeight: 0
    }
  }
}

// ---------------------------------------------------------------------------
// VPN Connection (Site-to-Site)
// ---------------------------------------------------------------------------

resource vpnConnection 'Microsoft.Network/vpnGateways/vpnConnections@2023-09-01' = if (deployVpnSite && deployVpnGateway) {
  parent: vpnGateway
  name: 'conn-${vpnSiteName}'
  properties: {
    remoteVpnSite: {
      id: vpnSite.id
    }
    connectionBandwidth: 100
    enableBgp: !empty(vpnSiteBgpPeeringAddress)
    vpnLinkConnections: [
      {
        name: 'link-${vpnSiteName}'
        properties: {
          vpnSiteLink: {
            id: '${vpnSite.id}/vpnSiteLinks/link-${vpnSiteName}'
          }
          connectionBandwidth: 100
          enableBgp: !empty(vpnSiteBgpPeeringAddress)
          vpnConnectionProtocolType: 'IKEv2'
        }
      }
    ]
    routingConfiguration: {
      associatedRouteTable: {
        id: defaultRouteTable.id
      }
      propagatedRouteTables: {
        ids: [
          {
            id: defaultRouteTable.id
          }
        ]
        labels: [
          'default'
        ]
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output vwanId string = vwan.id
output virtualHubId string = virtualHub.id
output vpnGatewayId string = deployVpnGateway ? vpnGateway.id : ''
