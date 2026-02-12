@description('Name of the Azure OpenAI resource')
param name string
@description('Deployment location')
param location string
@description('Id of the principal to assign Cognitive Services OpenAI User role (optional)')
param principalId string = ''
param tags object = {}

resource openAI 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
  }
}

// Deploy GPT-4 model for AI capabilities
resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAI
  name: 'gpt-4'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: 'turbo-2024-04-09'
    }
  }
}

// Deploy Phi-3 model
resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAI
  name: 'phi-3'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'phi-3'
      version: '1'
    }
  }
  dependsOn: [
    gptDeployment
  ]
}

// Optional: Assign Cognitive Services OpenAI User role to the principal
resource openAIUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(openAI.id, principalId, 'CognitiveServicesOpenAIUser')
  scope: openAI
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
    principalType: 'User'
  }
}

output endpoint string = openAI.properties.endpoint
output name string = openAI.name
output id string = openAI.id
