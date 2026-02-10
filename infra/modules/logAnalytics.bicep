param name string
param location string
param sku string = 'PerGB2018'
param retentionInDays int = 30

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    retentionInDays: retentionInDays
  }
}

output id string = workspace.id
output name string = workspace.name
