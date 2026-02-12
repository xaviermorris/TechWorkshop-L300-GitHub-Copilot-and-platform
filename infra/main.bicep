@description('Short environment name, e.g. dev, test, prod')
param env string = 'dev'
@description('Deployment location')
param location string = 'westus3'
@description('Prefix used for resource names')
param namePrefix string = 'zava'
@description('Image name and tag without registry, e.g. zavastorefront:latest')
param containerImageTag string = 'zavastorefront:latest'
@description('ACR SKU: Basic or Standard')
param acrSku string = 'Basic'
@description('App Service Plan SKU object')
param appServicePlanSku object = {
  name: 'B1'
  tier: 'Basic'
  size: 'B1'
  capacity: 1
}
@description('Enable App Service always-on')
param appServiceAlwaysOn bool = false
@description('Log Analytics retention in days')
param logAnalyticsRetentionDays int = 30
@description('Id of the principal to assign OpenAI roles (optional)')
param principalId string = ''
param tags object = {
  environment: env
  workload: 'zavastorefront'
}

// Unique suffix from resource group ID to ensure globally unique names
var uniqueSuffix = uniqueString(resourceGroup().id)
var acrName = '${namePrefix}${env}acr${uniqueSuffix}'
var planName = '${namePrefix}${env}asp'
var webAppName = '${namePrefix}${env}web'
var logAnalyticsName = '${namePrefix}${env}law'
var appInsightsName = '${namePrefix}${env}ai'
var openAIName = '${namePrefix}${env}oai${uniqueSuffix}'

module acr './modules/acr.bicep' = {
  name: 'acr'
  params: {
    name: acrName
    location: location
    sku: acrSku
    tags: tags
  }
}

module logAnalytics './modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsName
    location: location
    retentionInDays: logAnalyticsRetentionDays
    tags: tags
  }
}

module appInsights './modules/appInsights.bicep' = {
  name: 'appInsights'
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.id
    tags: tags
  }
}

module appServicePlan './modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: planName
    location: location
    sku: appServicePlanSku
    tags: tags
  }
}

module webApp './modules/webApp.bicep' = {
  name: 'webApp'
  params: {
    name: webAppName
    location: location
    planId: appServicePlan.outputs.id
    acrLoginServer: acr.outputs.loginServer
    containerImageTag: containerImageTag
    appInsightsConnectionString: appInsights.outputs.connectionString
    alwaysOn: appServiceAlwaysOn
    tags: union(tags, { 'azd-service-name': 'web' })
  }
}

module openAI './modules/openAI.bicep' = {
  name: 'openAI'
  params: {
    name: openAIName
    location: location
    principalId: principalId
    tags: tags
  }
}

// Existing view of the ACR for scoping role assignment
resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// AcrPull role assignment for the Web App managed identity
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, acrName, webAppName, 'AcrPull')
  scope: acrResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: webApp.outputs.identityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output acrName string = acrName
output acrLoginServer string = acr.outputs.loginServer
output webAppName string = webAppName
output webAppHostname string = webApp.outputs.defaultHostname
output appInsightsConnectionString string = appInsights.outputs.connectionString
output openAIEndpoint string = openAI.outputs.endpoint
output openAIName string = openAI.outputs.name