param appName string = 'zavastorefront'
param environmentName string = 'dev'
param location string = resourceGroup().location
param containerImageName string = 'zavastorefront'
param containerImageTag string = 'latest'
param acrSku string = 'Basic'
param appServiceSku string = 'B1'
param logAnalyticsSku string = 'PerGB2018'
param logRetentionInDays int = 30
param foundrySku string = 'S0'
param gptDeploymentName string = 'gpt-5-2'
param gptModelName string = 'gpt-5.2'
param gptModelVersion string = 'latest'
param phiDeploymentName string = 'phi'
param phiModelName string = 'phi'
param phiModelVersion string = 'latest'

var resourceToken = uniqueString(resourceGroup().id, appName, environmentName)
var normalizedName = toLower(replace(appName, '-', ''))
var acrName = take('${normalizedName}${environmentName}${resourceToken}', 50)
var appServicePlanName = '${appName}-${environmentName}-plan'
var appServiceName = '${appName}-${environmentName}-${resourceToken}'
var logAnalyticsName = '${appName}-${environmentName}-logs'
var appInsightsName = '${appName}-${environmentName}-appi'
var foundryName = take('${normalizedName}${environmentName}${resourceToken}ai', 64)

module logAnalytics './modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsName
    location: location
    sku: logAnalyticsSku
    retentionInDays: logRetentionInDays
  }
}

module appInsights './modules/appInsights.bicep' = {
  name: 'appInsights'
  params: {
    name: appInsightsName
    location: location
    workspaceId: logAnalytics.outputs.id
  }
}

module acr './modules/acr.bicep' = {
  name: 'acr'
  params: {
    name: acrName
    location: location
    sku: acrSku
  }
}

module appService './modules/appService.bicep' = {
  name: 'appService'
  params: {
    name: appServiceName
    location: location
    planName: appServicePlanName
    skuName: appServiceSku
    containerImage: '${acr.outputs.loginServer}/${containerImageName}:${containerImageTag}'
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    acrLoginServer: acr.outputs.loginServer
  }
}

module foundry './modules/foundry.bicep' = {
  name: 'foundry'
  params: {
    name: foundryName
    location: location
    skuName: foundrySku
    gptDeploymentName: gptDeploymentName
    gptModelName: gptModelName
    gptModelVersion: gptModelVersion
    phiDeploymentName: phiDeploymentName
    phiModelName: phiModelName
    phiModelVersion: phiModelVersion
  }
}

resource acrRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acr.outputs.name
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.outputs.acrId, appService.outputs.principalId, 'AcrPull')
  scope: acrRegistry
  properties: {
    principalId: appService.outputs.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalType: 'ServicePrincipal'
  }
}

output containerRegistryName string = acr.outputs.name
output containerRegistryLoginServer string = acr.outputs.loginServer
output webAppName string = appService.outputs.name
output webAppUrl string = 'https://${appService.outputs.defaultHostName}'
output appInsightsConnectionString string = appInsights.outputs.connectionString
output foundryName string = foundry.outputs.name
output foundryEndpoint string = foundry.outputs.endpoint
