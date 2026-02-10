param location string
param tags object
param resourceToken string
param principalId string

// Load abbreviations
var abbrs = loadJsonContent('./abbreviations.json')

// Log Analytics Workspace for Application Insights
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${abbrs.insightsComponents}${resourceToken}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: '${abbrs.containerRegistryRegistries}${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

// App Service Plan (Linux)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${abbrs.webServerFarms}${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// App Service
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: '${abbrs.webSitesAppService}${resourceToken}'
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/dotnet/aspnet:6.0'
      alwaysOn: false
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistry.properties.loginServer}'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
    }
  }
}

// Azure OpenAI (Microsoft Foundry)
resource openAI 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
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

// Deploy Phi model
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

// RBAC Role Assignment: AcrPull for App Service
resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, appService.id, 'AcrPull')
  scope: containerRegistry
  properties: {
    principalId: appService.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalType: 'ServicePrincipal'
  }
}

// Optional: Assign roles to the principal (if provided)
resource openAIUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(openAI.id, principalId, 'CognitiveServicesOpenAIUser')
  scope: openAI
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd') // Cognitive Services OpenAI User
    principalType: 'User'
  }
}

// Outputs
output CONTAINER_REGISTRY_ENDPOINT string = 'https://${containerRegistry.properties.loginServer}'
output CONTAINER_REGISTRY_NAME string = containerRegistry.name

output APP_SERVICE_NAME string = appService.name
output APP_SERVICE_URL string = 'https://${appService.properties.defaultHostName}'
output APP_SERVICE_IDENTITY_PRINCIPAL_ID string = appService.identity.principalId

output APPLICATIONINSIGHTS_CONNECTION_STRING string = appInsights.properties.ConnectionString
output APPLICATIONINSIGHTS_NAME string = appInsights.name

output AZURE_OPENAI_ENDPOINT string = openAI.properties.endpoint
output AZURE_OPENAI_NAME string = openAI.name

output LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id
