param location string
param gwVmSubnetId string
param spokeSubnetId string
param adminuser string
param adminpw string

resource vmnicgwsn 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'nic-vm-gwsn'
  location: location
  properties: {
    enableIPForwarding: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gwVmSubnetId
          }
        }
      }
    ]
  }
}

resource vmnicspsn 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'nic-vm-spsn'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: spokeSubnetId
          }
        }
      }
    ]
  }
}

resource vmgwsn 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'vm-gwsn'
  location: location
  identity: {
     type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS2_v2'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
         publisher: 'Canonical'
         offer: '0001-com-ubuntu-server-jammy'
         sku: '22_04-lts-gen2'
         version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
         {
          id: vmnicgwsn.id
         }
      ]
    }
    osProfile: {
      computerName: 'vm-gwsn'
      adminUsername: adminuser
      adminPassword: adminpw
    }
  }
}

resource vmspsn 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'vm-spsn'
  location: location
  properties: {
    hardwareProfile: {
      vmSize:  'Standard_DS2_v2'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
         publisher: 'MicrosoftWindowsServer'
         offer: 'WindowsServer'
         sku: '2022-datacenter-smalldisk-g2'
         version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
         {
          id: vmnicspsn.id
         }
      ]
    }
    osProfile: {
      computerName: 'vm-gwsn'
      adminUsername: adminuser
      adminPassword: adminpw
    }
  }
}
