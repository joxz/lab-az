param vpngwName string
param location string
param gwSubnetId string
param sharedkey string

resource lngzscalerfra4 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: 'lng-zscaler-fra4'
  location: location
  properties: {
    fqdn: 'fra4-vpn.zscaler.net'
    localNetworkAddressSpace: {
      addressPrefixes: [
        '0.0.0.0/1'
        '128.0.0.0/1'
      ]
    }
  }
}

resource lngzscalerams2 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: 'lng-zscaler-ams2'
  location: location
  properties: {
    fqdn: 'ams2-2-vpn.zscaler.net'
    localNetworkAddressSpace: {
      addressPrefixes: [
        '0.0.0.0/1'
        '128.0.0.0/1'
      ]
    }
  }
}

resource vpngwpip01 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'vpngw-pip01'
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
  name: 'vpngw-pip02'
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
    enablePrivateIpAddress: true
    activeActive: true
    enableBgp: false
    vpnGatewayGeneration: 'Generation2'
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        id: vpngwpip01.id
        properties: {
          subnet: {
            id: gwSubnetId
          }
        }
      }
      {
        id: vpngwpip02.id
        properties: {
          subnet: {
            id: gwSubnetId
          }
        }
      }
    ]
  }
}

// https://help.zscaler.com/zia/understanding-ipsec-vpns
resource connectiontozscaler 'Microsoft.Network/connections@2022-07-01' = {
  name: 's2s-zscaler'
  location: location
  properties: {
    sharedKey: sharedkey
    connectionMode: 'Default'
    connectionProtocol: 'IKEv2'
    connectionType: 'IPsec'
    dpdTimeoutSeconds: 20
    enableBgp: false
    useLocalAzureIpAddress: false
    virtualNetworkGateway1: vpngw
    localNetworkGateway2: lngzscalerams2
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
