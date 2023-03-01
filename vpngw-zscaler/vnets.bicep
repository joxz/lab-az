param gwVnetName string
param gwPrefix string
param spokeVnetName string
param spokePrefix string
param location string = resourceGroup().location

var gwSubnetPrefix = split(gwPrefix, '/')[0]
var spokeSubnetPrefix = split(spokePrefix, '/')[0]

resource gwvnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: gwVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [gwPrefix]
    }
  }
}

resource gwsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: 'GatewaySubnet'
  parent: gwvnet
  properties: {
    addressPrefix: '${gwSubnetPrefix}/24'
  }
}

resource spokevnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [spokePrefix]
    }
  }
}

resource spokesubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: 'default'
  parent: spokevnet
  properties: {
    addressPrefix: '${spokeSubnetPrefix}/24'
  }
}

resource peeringgwtospoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'gw-to-spoke-peering'
  parent: gwvnet
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: spokevnet.id
    }
  }
}

resource peeringspoketogw 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'spoke-to-gw-peering'
  parent: spokevnet
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: gwvnet.id
    }
    useRemoteGateways: true
  }
}

output gwVnetId string = gwvnet.id
output gwSubnetId string = gwsubnet.id
output spokeVnetId string = spokevnet.id
output spokeSubnetId string = spokesubnet.id
