targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The Azure admin alias (admin@domain.onmicrosoft.com) to deploy the resources to')
param adminalias string

@description('Connections object for the Logic App.')


// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
  'SecurityControl': 'Ignore'
}
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// This deploys the Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module resources './resources.bicep' = {
  name: 'fabric'
  scope: rg
  params: {
    fabricName: 'fabric${resourceToken}'
    evhubnamespace: 'evhub${resourceToken}'
    evhubname: 'evhub${resourceToken}'
    location: location
    admin: adminalias
    sku: 'F2'
  }
}


// Outputs are automatically saved in the local azd environment .env file.
// To see these outputs, run `azd env get-values`,  or `azd env get-values --output json` for json output.
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_FABRIC_ID string = resources.outputs.fabricId
output AZURE_FABRIC_NAME string = resources.outputs.fabricName
