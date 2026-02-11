param name string
param location string
param retentionInDays int = 30
param tags object = {}

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  properties: {
    retentionInDays: retentionInDays
    features: {
      searchVersion: 2
    }
  }
  tags: tags
}

output id string = workspace.id
