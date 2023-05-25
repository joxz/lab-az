param location string = 'brazilsouth'
param regionname string = 'BRS'

resource zpavm1 'Microsoft.Compute/virtualMachines@2022-11-01' existing = {
  name: 'AZ-BRS-PROD-ZPA-VM01'
  scope: resourceGroup('AZ-BRS-PROD-ZPA-RG01')
}

resource zpacm 'Microsoft.Network/networkWatchers/connectionMonitors@2022-07-01' = {
  name: 'ZPA-${regionname}-CM01'
  location: location
  properties: {
    autoStart: true
    endpoints: [
      {
        address: '10.0.210.100'
        name: ''
      }
    ]
  }
}
