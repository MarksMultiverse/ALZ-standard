targetScope= 'subscription'

// General parameters
param custPrefix string = 'qiz'
param subPrefix string = 'connectivity'
param location string = 'westeurope'
param Tags object = {
  Environment: 'Prod'
  Department: 'IT'
  Supportedby: 'Pink'
}

// VNET parameters
param vnetAddressPrefix string ='10.210.0.0/23'
param subnet1Prefix string = '10.210.1.0/24'
param GatewaySubnetPrefix string = '10.210.0.0/27'
param bastionSubnetPrefix string = '10.210.0.32/28'

// VPN parameters
param LocalNetworkGateway1destination string = 'test'
param LocalNetworkGateway1addressprefixes array = [
  '10.10.0.0/23'
  '10.79.0.0/23'
]
param LocalNetworkGateway1GatewayAddress string = '10.40.5.6'
param connection1sharedkey string = ''

// Create resourcegroups
resource rgcore 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-pl-${subPrefix}-core-prd-001'
  location: location
}

resource rgnet 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${custPrefix}-pl-${subPrefix}-net-prd-001'
  location: location
}

//Import modules
module network '1.1-network.bicep' = {
  scope: rgnet
  name: 'NetworkDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    subPrefix: subPrefix
    Tags: Tags
    vnetAddressPrefix: vnetAddressPrefix
    subnet1Prefix: subnet1Prefix
    GatewaySubnetPrefix: GatewaySubnetPrefix
    bastionSubnetPrefix: bastionSubnetPrefix
    LocalNetworkGateway1addressprefixes: LocalNetworkGateway1addressprefixes
    LocalNetworkGateway1destination: LocalNetworkGateway1destination
    LocalNetworkGateway1GatewayAddress: LocalNetworkGateway1GatewayAddress
    connection1sharedkey: connection1sharedkey
  }
}

module core '1.2-core.bicep' = {
  scope: rgcore
  name: 'CoreDeployment'
  params: {
    custPrefix: custPrefix
    location: location
    Tags: Tags
    subPrefix: subPrefix
  }
  dependsOn: [
    network
  ]
}
