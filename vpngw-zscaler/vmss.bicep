param location string
param gwVmSubnetId string
param adminuser string
param adminpw string

var ilbName = 'ilb-zsc'

resource ilb 'Microsoft.Network/loadBalancers@2022-07-01' = {
  name: ilbName
  location: location
  sku: {
    name:'Standard'
    tier: 'Regional'
  }
  properties: {
     frontendIPConfigurations: [
      {
        name: 'frontend-zsc'
        properties: {
          privateIPAddress: '10.1.1.200'
          privateIPAllocationMethod: 'Static'
          subnet:  {
            id: gwVmSubnetId
          }
          privateIPAddressVersion: 'IPv4'
        }
      }
     ]
     backendAddressPools: [
       {
        name: 'backend-zsc'
       }
     ]
     loadBalancingRules: [
       {
        properties: {
          frontendPort: 0
          protocol:  'All'
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', ilbName, 'frontend-zsc')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', ilbName, 'backend-zsc')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', ilbName, 'probe-zsc')
          }
          enableFloatingIP: false
          enableTcpReset: false
          disableOutboundSnat: true
          loadDistribution:  'SourceIP'
        }
       }
     ]
     probes: [
       {
        name: 'probe-zsc'
        properties: {
          protocol: 'Tcp'
          port: 22
          intervalInSeconds: 5
          numberOfProbes: 1
          probeThreshold: 1
        }
       }
     ]
     inboundNatRules: []
     outboundRules: []
     inboundNatPools: []
  }
}

resource vmssgwsn 'Microsoft.Compute/virtualMachineScaleSets@2022-11-01' = {
  name: 'vmss-gwsn'
  location: location
  sku:{
    name: 'Standard_D2s_v3'
    tier: 'Standard'
    capacity: 1
  }
  zones: [
    '1'
    '3'
  ]
  properties: {
    singlePlacementGroup: false
    orchestrationMode: 'Uniform'
    upgradePolicy: {
      mode: 'Manual'
    }
    scaleInPolicy: {
      rules: [
        'Default'
      ]
      forceDeletion: false
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'vmss-gwsn'
        adminUsername: adminuser
        adminPassword: adminpw
        customData: loadFileAsBase64('cloud-config.yml')
        linuxConfiguration: {
          disablePasswordAuthentication: false
          provisionVMAgent: true
          enableVMAgentPlatformUpdates: false
        }
        secrets: []
        allowExtensionOperations: true
        requireGuestProvisionSignal: true
      }
      storageProfile: {
        osDisk: {
          osType: 'Linux'
          diffDiskSettings: {
            option: 'Local'
            placement: 'CacheDisk'
          }
          createOption: 'FromImage'
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
          diskSizeGB: 30
        }
        imageReference: {
          publisher: 'canonical'
          offer: '0001-com-ubuntu-server-jammy'
          sku: '22_04-lts-gen2'
          version: 'latest'
        }
      }
      networkProfile: {
        healthProbe: {
          id: resourceId('Microsoft.Network/loadBalancers/probes', ilbName, 'probe-zsc')
        }
        networkInterfaceConfigurations: [
          {
            name: 'nic-vmss-gwsn'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              disableTcpStateTracking: false
              enableIPForwarding: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    primary: true
                    subnet: {
                      id: gwVmSubnetId
                    }
                    privateIPAddressVersion: 'IPv4'
                    loadBalancerBackendAddressPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', ilbName, 'backend-zsc')
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
    }
    overprovision: false
    doNotRunExtensionsOnOverprovisionedVMs: false
    zoneBalance: false
    platformFaultDomainCount: 1
    automaticRepairsPolicy: {
      enabled: false
      gracePeriod: 'PT10M'
    }
  }
  dependsOn: [
    ilb
  ]
}


