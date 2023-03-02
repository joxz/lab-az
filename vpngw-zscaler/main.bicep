// Setting target scope
targetScope = 'subscription'

// parameters
param location string = 'westeurope'
param sharedkey string = '42376462378462hdjshjksdchvjkkbc'
param dateTime string = utcNow()
param adminuser string = 'jo'
param adminpw string = 'test123!Test123'
param zscalernode1 string = 'fra4-vpn.zscaler.net'
param zscalernode2 string = 'ams2-2-vpn.zscaler.net'

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-zsc-vpngw'
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
    spokePrefix: '10.8.0.0/16'
    location: location
  }
}

module vms './vms.bicep' = {
  name: 'vmDeployment-${dateTime}'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    location: location
    gwVmSubnetId: vnets.outputs.gwVmSubnetId
    spokeSubnetId: vnets.outputs.spokeSubnetId
    adminuser: adminuser
    adminpw: adminpw
  }
}

module vmss './vmss.bicep' = {
  name: 'vmssDeployment-${dateTime}'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    location: location
    gwVmSubnetId: vnets.outputs.gwVmSubnetId
    adminuser: adminuser
    adminpw: adminpw
  }
}

module bastion './bastion.bicep' = {
  name: 'bastionDeployment-${dateTime}'
  scope: rg
  params: {
    bastionSubnetId : vnets.outputs.bastionSubnetId
    location: location
  }
}

module vpngw './vpngw.bicep' = {
  name: 'vpngwDeployment-${dateTime}'
  scope: rg    // Deployed in the scope of resource group we created above
  params: {
    vpngwName: 'vpngw-zsc'
    location: location
    gwSubnetId: vnets.outputs.gwSubnetId
    sharedkey: sharedkey
    zscalerNode1: zscalernode1
    zscalerNode2: zscalernode2
  }
}
