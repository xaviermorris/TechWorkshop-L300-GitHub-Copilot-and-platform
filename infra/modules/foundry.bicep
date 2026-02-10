param name string
param location string
param skuName string = 'S0'
param gptDeploymentName string = 'gpt-5-2'
param gptModelName string = 'gpt-5.2'
param gptModelVersion string = 'latest'
param phiDeploymentName string = 'phi'
param phiModelName string = 'phi'
param phiModelVersion string = 'latest'

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  kind: 'OpenAI'
  sku: {
    name: skuName
  }
  properties: {
    customSubDomainName: name
  }
}

resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: '${account.name}/${gptDeploymentName}'
  properties: {
    model: {
      format: 'OpenAI'
      name: gptModelName
      version: gptModelVersion
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
}

resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: '${account.name}/${phiDeploymentName}'
  properties: {
    model: {
      format: 'OpenAI'
      name: phiModelName
      version: phiModelVersion
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
}

output name string = account.name
output endpoint string = account.properties.endpoint
