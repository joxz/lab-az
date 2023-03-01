param vpngwName string
param location string
param gwSubnetId string
param sharedkey string
param zscalerNode1 string
param zscalerNode2 string

resource lngzscaler1 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: 'lng-zsc-fra4'
  location: location
  properties: {
    fqdn: zscalerNode1
    localNetworkAddressSpace: {
      addressPrefixes: [
        '0.0.0.0/1'
        '128.0.0.0/1'
      ]
    }
  }
}

resource lngzscaler2 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: 'lng-zsc-ams2'
  location: location
  properties: {
    fqdn: zscalerNode2
    localNetworkAddressSpace: {
      addressPrefixes: [
        '0.0.0.0/1'
        '128.0.0.0/1'
      ]
    }
  }
}

resource vpngwpip01 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'pip-vpngw01'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource vpngwpip02 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'pip-vpngw02'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource vpngw 'Microsoft.Network/virtualNetworkGateways@2022-07-01' = {
  name: vpngwName
  location: location
  properties: {
    allowRemoteVnetTraffic: true
    enablePrivateIpAddress: true
    activeActive: true
    enableBgp: false
    vpnGatewayGeneration: 'Generation2'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'pip-01'
        properties: {
          publicIPAddress: {
            id: vpngwpip01.id
          }
          subnet: {
            id: gwSubnetId
          }
        }
      }
      {
        name: 'pip-02'
        properties: {
          publicIPAddress: {
            id: vpngwpip02.id
          }
          subnet: {
            id: gwSubnetId
          }
        }
      }
    ]
  }
}

// https://help.zscaler.com/zia/understanding-ipsec-vpns
resource conntozscalerfra 'Microsoft.Network/connections@2022-07-01' = {
  name: 's2s-zsc-${zscalerNode1}'
  location: location
  properties: {
    sharedKey: sharedkey
    connectionMode: 'Default'
    connectionProtocol: 'IKEv2'
    connectionType: 'IPsec'
    dpdTimeoutSeconds: 20
    enableBgp: false
    useLocalAzureIpAddress: false
    virtualNetworkGateway1:  {
      id: vpngw.id
      properties: {}
    }
    localNetworkGateway2: {
      id: lngzscaler1.id
      properties: {}
    }
    ipsecPolicies: [
      {
        dhGroup: 'DHGroup2'
        ikeEncryption: 'AES256'
        ikeIntegrity: 'SHA256'
        ipsecEncryption: 'None'
        ipsecIntegrity: 'SHA256'
        pfsGroup: 'None'
        saDataSizeKilobytes: 102400000
        saLifeTimeSeconds: 28800
      }
    ]
  }
}
resource conntozscalerams 'Microsoft.Network/connections@2022-07-01' = {
  name: 's2s-zsc-${zscalerNode2}'
  location: location
  properties: {
    sharedKey: sharedkey
    connectionMode: 'Default'
    connectionProtocol: 'IKEv2'
    connectionType: 'IPsec'
    dpdTimeoutSeconds: 20
    enableBgp: false
    useLocalAzureIpAddress: false
    virtualNetworkGateway1: {
      id: vpngw.id
      properties: {}
    }
    localNetworkGateway2:  {
      id: lngzscaler2.id
      properties: {}
    }
    ipsecPolicies: [
      {
        dhGroup: 'DHGroup2'
        ikeEncryption: 'AES256'
        ikeIntegrity: 'SHA256'
        ipsecEncryption: 'None'
        ipsecIntegrity: 'SHA256'
        pfsGroup: 'None'
        saDataSizeKilobytes: 102400000
        saLifeTimeSeconds: 28800
      }
    ]
  }
}
