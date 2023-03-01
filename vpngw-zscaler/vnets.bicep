param gwVnetName string
param gwPrefix string
param spokeVnetName string
param spokePrefix string
param location string = resourceGroup().location

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
    addressPrefix: '10.1.0.0/24'
  }
}

resource gwclientsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: 'gw-sn01'
  parent: gwvnet
  properties: {
    addressPrefix: '10.1.1.0/24'
  }
  dependsOn: [
    gwsubnet
  ]
}

resource bastionsubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: 'AzureBastionSubnet'
  parent: gwvnet
  properties: {
    addressPrefix: '10.1.2.0/24'
  }
  dependsOn: [
    gwclientsubnet
  ]
}

resource spokevnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [spokePrefix]
    }
  }
  dependsOn: [
    gwclientsubnet
  ]
}

resource spokesubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: 'spoke-sn01'
  parent: spokevnet
  properties: {
    addressPrefix: '10.8.0.0/24'
  }
}

resource peeringgwtospoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'gw-to-spoke-peering'
  parent: gwvnet
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: spokevnet.id
    }
  }
  dependsOn: [
    spokesubnet, gwclientsubnet, gwsubnet, bastionsubnet
  ]
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
  }
  dependsOn: [
    peeringgwtospoke
  ]
}

output gwVnetId string = gwvnet.id
output gwSubnetId string = gwsubnet.id
output gwClientSubnetId string = gwclientsubnet.id
output spokeVnetId string = spokevnet.id
output spokeSubnetId string = spokesubnet.id
output bastionSubnetId string = bastionsubnet.id
