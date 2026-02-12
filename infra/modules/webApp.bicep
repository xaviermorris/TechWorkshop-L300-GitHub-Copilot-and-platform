param name string
param location string
param planId string
param acrLoginServer string
@description('Image name and tag without registry, e.g. zavastorefront:latest')
param containerImageTag string
param appInsightsConnectionString string
@description('Port the container listens on')
param containerPort int = 8080
param alwaysOn bool = false
param tags object = {}

var fullImage = '${acrLoginServer}/${containerImageTag}'

resource site 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: planId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${fullImage}'
      acrUseManagedIdentityCreds: true
      alwaysOn: alwaysOn
      ftpsState: 'Disabled'
      httpLoggingEnabled: true
      detailedErrorLoggingEnabled: true
      requestTracingEnabled: true
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: string(containerPort)
        }
        {
          name: 'ASPNETCORE_URLS'
          value: 'http://+:${containerPort}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
      ]
    }
  }
  tags: tags
}

output id string = site.id
output defaultHostname string = site.properties.defaultHostName
output identityPrincipalId string = site.identity.principalId
