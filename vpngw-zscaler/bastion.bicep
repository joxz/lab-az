param bastionSubnetId string
param location string

resource baspip01 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'pip-bas01'
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

resource bastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: 'bas-zsc'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    disableCopyPaste: false
    enableFileCopy: true
    enableTunneling: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          publicIPAddress: {
            id: baspip01.id
          }
          subnet: {
            id: bastionSubnetId
          }
        }
      }
    ]
    scaleUnits: 2
  }
}
