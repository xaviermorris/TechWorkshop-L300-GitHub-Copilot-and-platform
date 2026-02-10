targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment used for naming resources')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = 'westus3'

@description('Id of the principal to assign database and application roles')
param principalId string = ''

// Tags to apply to all resources
var tags = {
  'azd-env-name': environmentName
  environment: 'dev'
}

// Generate unique resource names
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Deploy main resources
module resources './resources.bicep' = {
  name: 'resources'
  scope: rg
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
    principalId: principalId
  }
}

// Outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = resources.outputs.CONTAINER_REGISTRY_ENDPOINT
output AZURE_CONTAINER_REGISTRY_NAME string = resources.outputs.CONTAINER_REGISTRY_NAME

output APP_SERVICE_NAME string = resources.outputs.APP_SERVICE_NAME
output APP_SERVICE_URL string = resources.outputs.APP_SERVICE_URL

output APPLICATIONINSIGHTS_CONNECTION_STRING string = resources.outputs.APPLICATIONINSIGHTS_CONNECTION_STRING
output APPLICATIONINSIGHTS_NAME string = resources.outputs.APPLICATIONINSIGHTS_NAME

output AZURE_OPENAI_ENDPOINT string = resources.outputs.AZURE_OPENAI_ENDPOINT
output AZURE_OPENAI_NAME string = resources.outputs.AZURE_OPENAI_NAME
