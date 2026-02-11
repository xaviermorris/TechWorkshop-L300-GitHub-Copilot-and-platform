# Infrastructure

This folder contains Bicep modules to deploy the Zava Storefront dev environment.

## Resources
- Azure Container Registry (ACR) with admin disabled
- Log Analytics workspace + Application Insights
- Linux App Service Plan + Web App for Containers (system-assigned managed identity, ACR pull via AcrPull role)

## Parameters (main.bicep)
- `env`: environment short name (default `dev`)
- `location`: region (default `westus3`)
- `namePrefix`: resource name prefix (default `zava`)
- `containerImageTag`: image name:tag without registry (default `zavastorefront:latest`)
- `acrSku`: ACR SKU (`Basic` or `Standard`)
- `appServicePlanSku`: object `{ name, tier, size, capacity }` (default Basic B1)
- `appServiceAlwaysOn`: enable AlwaysOn on the Web App (default false)
- `logAnalyticsRetentionDays`: retention for Log Analytics

## Usage
1. Build and push an image to ACR (cloud build example):
   ```sh
   az acr build -r <acrName> -t zavastorefront:<env> .
   ```
   Then set `containerImageTag=zavastorefront:<env>` when provisioning/deploying.
2. Initialize AZD at repo root:
   ```sh
   azd init
   ```
3. Preview and provision:
   ```sh
   azd provision --preview
   azd up
   ```

> Note: Microsoft Foundry resource is not scaffolded because the provider schema was not discoverable here. Add it later as a separate module once the correct resource type/API version is confirmed for westus3.
