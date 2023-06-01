param location string = 'brazilsouth'
param regionname string = 'BRS'
param workspaceid string = '/subscriptions/69edfa5f-1768-49f6-a67e-12ebb19579fb/resourceGroups/AZ-WEUR-SEC-LOGS-RG01/providers/Microsoft.OperationalInsights/workspaces/AZ-${regionname}-SEC-LOG01'

resource zpavm1 'Microsoft.Compute/virtualMachines@2022-11-01' existing = {
  name: 'AZ-${regionname}-PROD-ZPA-VM01'
  scope: resourceGroup('AZ-${regionname}-PROD-ZPA-RG01')
}

resource zpavm2 'Microsoft.Compute/virtualMachines@2022-11-01' existing = {
  name: 'AZ-${regionname}-PROD-ZPA-VM02'
  scope: resourceGroup('AZ-${regionname}-PROD-ZPA-RG01')
}

resource networkwatcher 'Microsoft.Network/networkWatchers@2022-07-01' existing = {
  name: 'NetworkWatcher_${location}'
}

resource zpacm 'Microsoft.Network/networkWatchers/connectionMonitors@2022-07-01' = {
  name: 'ZPA-${regionname}-CM01'
  parent: networkwatcher
  location: location
  properties: {
    endpoints: [
      {
        name: zpavm1.name
        type: 'AzureVM'
        resourceId: zpavm1.id
      }
      {
        name: zpavm2.name
        type: 'AzureVM'
        resourceId: zpavm2.id
      }
      {
        name: 'graph.microsoft.com'
        address: 'graph.microsoft.com'
        type: 'ExternalAddress'
      }
      {
        name: 'login.microsoft.com'
        address: 'login.microsoft.com'
        type: 'ExternalAddress'
      }
      {
        name: 'office.live.com'
        address: 'goffice.live.com'
        type: 'ExternalAddress'
      }
      {
        name: 'outlook.office365.com'
        address: 'outlook.office365.com'
        type: 'ExternalAddress'
      }
      {
        name: 'smtp.office365.com'
        address: 'smtp.office365.com'
        type: 'ExternalAddress'
      }
      {
        name: 'teams.microsoft.com'
        address: 'teams.microsoft.com'
        type: 'ExternalAddress'
      }
      {
        name: 'www.google.com'
        address: 'www.google.com'
        type: 'ExternalAddress'
      }
      {
        name: 'www.knauf.com'
        address: 'www.knauf.com'
        type: 'ExternalAddress'
      }
      {
        name: '10.0.217.225'
        address: '10.0.217.225'
        type: 'ExternalAddress'
      }
      {
        name: '10.0.210.100'
        address: '10.0.210.100'
        type: 'ExternalAddress'
      }
      {
        name: 'compass.knaufgroup.com'
        address: 'compass.knaufgroup.com'
        type: 'ExternalAddress'
      }
      {
        name: 'fra4.sme.zscaler.net'
        address: 'fra4.sme.zscaler.net'
        type: 'ExternalAddress'
      }
      {
        name: 'sin4.sme.zscaler.net'
        address: 'sin4.sme.zscaler.net'
        type: 'ExternalAddress'
      }
      {
        name: 'gateway.zscaler.net'
        address: 'gateway.zscaler.net'
        type: 'ExternalAddress'
      }
      {
        name: '10.206.9.180'
        address: '10.206.9.180'
        type: 'ExternalAddress'
      }
      {
        name: '10.206.8.69'
        address: '10.206.8.69'
        type: 'ExternalAddress'
      }
      {
        name: 'mobile.zscaler.net'
        address: 'mobile.zscaler.net'
        type: 'ExternalAddress'
      }
      {
        name: 'pac.zscaler.net'
        address: 'http://pac.zscaler.net/group.knauf.loc/wpad.pac'
        type: 'ExternalAddress'
      }
    ]
    outputs: [
      {
        type: 'Workspace'
        workspaceSettings: {
          workspaceResourceId: workspaceid
        }
      }
    ]
    testConfigurations: [
      {
        name: 'icmp'
        protocol: 'Icmp'
        icmpConfiguration: {
          disableTraceRoute: false
        }
        testFrequencySec: 30
        successThreshold: {}
      }
      {
        name: 'https'
        protocol: 'Http'
        httpConfiguration: {
          port: 443
          method: 'Get'
          preferHTTPS: true
          requestHeaders: []
          path: ''
        }
        testFrequencySec: 30
        successThreshold: {}
      }
      //{
      //  name: 'http'
      //  protocol: 'Http'
      //  httpConfiguration: {
      //    port: 80
      //    method: 'Get'
      //    preferHTTPS: true
      //    requestHeaders: []
      //    path: ''
      //  }
      //  testFrequencySec: 30
      //  successThreshold: {}
      //}
      {
        name: 'tcp-10129'
        protocol: 'Tcp'
        tcpConfiguration: {
          destinationPortBehavior: 'ListenIfAvailable'
          disableTraceRoute: false
          port: 10129
        }
        testFrequencySec: 30
        successThreshold: {}
      }
      //{
      //  name: 'tcp-80'
      //  protocol: 'Tcp'
      //  tcpConfiguration: {
      //    destinationPortBehavior: 'ListenIfAvailable'
      //    disableTraceRoute: false
      //    port: 80
      //  }
      //  testFrequencySec: 30
      //  successThreshold: {}
      //}
      {
        name: 'tcp-443'
        protocol: 'Tcp'
        tcpConfiguration: {
          destinationPortBehavior: 'ListenIfAvailable'
          disableTraceRoute: false
          port: 443
        }
        testFrequencySec: 30
        successThreshold: {}
      }
      {
        name: 'tcp-53'
        protocol: 'Tcp'
        tcpConfiguration: {
          destinationPortBehavior: 'ListenIfAvailable'
          disableTraceRoute: true
          port: 53
        }
        testFrequencySec: 30
        successThreshold: {}
      }
    ]
    testGroups: [
      {
        name: 'o365'
        destinations: [
          'graph.microsoft.com', 'login.microsoft.com', 'office.live.com', 'outlook.office365.com', 'smtp.office365.com', 'teams.microsoft.com'
        ]
        sources: [
          '${zpavm1.name}', '${zpavm2.name}'
        ]
        testConfigurations: [
          'https'
        ]
      }
      {
        name: 'onpremise'
        destinations: [
          '10.0.217.225', '10.0.210.100', 'compass.knaufgroup.com'
        ]
        sources: [
          '${zpavm1.name}', '${zpavm2.name}'
        ]
        testConfigurations: [
          'icmp', 'tcp-443'
        ]
      }
      {
        name: 'internet'
        destinations: [
          'www.google.com', 'www.knauf.com'
        ]
        sources: [
          '${zpavm1.name}', '${zpavm2.name}'
        ]
        testConfigurations: [
          'https'
        ]
      }
      {
        name: 'zscaler_nodes'
        destinations: [
          'fra4.sme.zscaler.net', 'sin4.sme.zscaler.net', 'gateway.zscaler.net'
        ]
        sources: [
          '${zpavm1.name}', '${zpavm2.name}'
        ]
        testConfigurations: [
          'tcp-10129'
        ]
      }
      {
        name: 'zscaler_svc'
        destinations: [
          'pac.zscaler.net', 'mobile.zscaler.net'
        ]
        sources: [
          '${zpavm1.name}', '${zpavm2.name}'
        ]
        testConfigurations: [
          'https'
        ]
      }
      {
        name: 'dns'
        destinations: [
          '10.206.9.180', '10.206.8.69'
        ]
        sources: [
          '${zpavm1.name}', '${zpavm2.name}'
        ]
        testConfigurations: [
          'tcp-53'
        ]
      }
    ]
  }
}
