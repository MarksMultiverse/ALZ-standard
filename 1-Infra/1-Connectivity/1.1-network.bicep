// General parameters
param custPrefix string
param subPrefix string
param location string
param Tags object
// VNET parameters
param vnetAddressPrefix string
param subnet1Prefix string
param GatewaySubnetPrefix string
param bastionSubnetPrefix string
// VPN parameters
param LocalNetworkGateway1destination string
param LocalNetworkGateway1addressprefixes array
param LocalNetworkGateway1GatewayAddress string
param connection1sharedkey string


//Create VNET with a three subnets
resource vnetcon 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: '${custPrefix}-vnet-pl-con-prd-westeu-001'
  location: location
  tags: Tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: GatewaySubnetPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetPrefix
        }
      }
      {
        name: '${custPrefix}-snet-pl-con-prd-001'
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: {
            id: nsgcon.id
          }
        }
      }
    ]
  }
}

// Create Network Security Group
resource nsgcon 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: '${custPrefix}-nsg-snet-pl-con-prd-001'
  location: location
  tags: Tags
}

//Creating Public IP address for the Virtual network Gateway
resource vngpip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${custPrefix}-pip-pl-con-prd-001'
  location: location
  tags: Tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
  zones:[
    '2'
    '3'
    '1'
  ]
}

//Creating Public IP address for Azure Bastion
resource bastionpip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${custPrefix}-pip-pl-con-prd-002'
  location: location
  tags: Tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//Creating Virtual Network Gateway
resource vngcon 'Microsoft.Network/virtualNetworkGateways@2022-07-01' = {
  name: '${custPrefix}-vng-pl-con-prd-001'
  location: location
  tags: Tags
  properties: {
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('${custPrefix}-pl-${subPrefix}-net-prd-001', 'Microsoft.Network/virtualNetworks/subnets','${custPrefix}-vnet-pl-con-prd-westeu-001','GatewaySubnet')
          }
          publicIPAddress: {
            id: vngpip.id
          }
        }
      }
    ]
    
  }
  dependsOn: [
    vnetcon
  ]
}

//Creating Local Network Gateway 1
resource LocalNetworkGatewayconnection1 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: '${custPrefix}-lng-pl-con-${LocalNetworkGateway1destination}-prd-001'
  location: location
  tags: Tags
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: LocalNetworkGateway1addressprefixes
    }
    gatewayIpAddress: LocalNetworkGateway1GatewayAddress
  }
}

//Creating Connection between Virtual Network Gateway and Local Network Gateway 1
resource connection1 'Microsoft.Network/connections@2022-07-01' = {
  name: '${custPrefix}-con-pl-con-${LocalNetworkGateway1destination}-prd-001'
  location: location
  tags: Tags
  properties: {
    connectionType: 'IPsec'
    virtualNetworkGateway1: {
      id: vngcon.id
      properties: {
        
      }
    }
    enableBgp: false
    sharedKey: connection1sharedkey
    connectionProtocol: 'IKEv2'
    localNetworkGateway2: {
      id: LocalNetworkGatewayconnection1.id
      properties: {
      }
    }
  }
}
