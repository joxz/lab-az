// Setting target scope
targetScope = 'subscription'

// parameters
param location string = 'westeurope'
param sharedkey string = '42376462378462hdjshjksdchvjkkbc'
param dateTime string = utcNow()

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-vpn-zscaler'
  location: location
  tags: {
    CostCenter: '12345'
  }
}

module vnets './vnets.bicep' = {
  name: 'vnetDeployment-${dateTime}'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    gwVnetName: 'vnet-gw'
    gwPrefix: '10.1.0.0/16'
    spokeVnetName: 'vnet-spoke'
    spokePrefix: '10.2.0.0/16'
    location: location
  }
}

module vpngw './vpngw.bicep' = {
  name: 'vpngwDeployment-${dateTime}'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    vpngwName: 'vpngw'
    location: location
    gwSubnetId: vnets.outputs.gwSubnetId
    sharedkey: sharedkey
  }
}
