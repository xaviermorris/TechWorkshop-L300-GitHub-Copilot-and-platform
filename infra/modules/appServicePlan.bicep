param name string
param location string
@description('SKU object e.g. { name: "B1", tier: "Basic", size: "B1", capacity: 1 }')
param sku object
param tags object = {}

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  kind: 'linux'
  sku: sku
  properties: {
    reserved: true
  }
  tags: tags
}

output id string = plan.id
