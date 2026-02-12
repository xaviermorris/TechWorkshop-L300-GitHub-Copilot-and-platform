# Azure Infrastructure for ZavaStorefront

This directory contains the Azure infrastructure as code (IaC) using Bicep templates for the ZavaStorefront web application.

## Architecture Overview

The infrastructure includes:

- **Azure Container Registry**: For storing Docker container images
- **Azure App Service (Linux)**: Hosting the containerized .NET application
- **Application Insights**: For monitoring and diagnostics
- **Log Analytics Workspace**: For centralized logging
- **Azure OpenAI (Microsoft Foundry)**: For AI capabilities with GPT and Phi models

## Bicep Structure

- `infra/main.bicep` - Main orchestrator, resource-group-level deployment
- `infra/modules/acr.bicep` - Azure Container Registry (admin disabled)
- `infra/modules/appServicePlan.bicep` - Linux App Service Plan
- `infra/modules/webApp.bicep` - Web App for Containers (managed identity)
- `infra/modules/logAnalytics.bicep` - Log Analytics Workspace
- `infra/modules/appInsights.bicep` - Application Insights
- `infra/modules/openAI.bicep` - Azure OpenAI with GPT-4 and Phi-3 deployments

## Key Features

- **RBAC-based Authentication**: App Service uses managed identity to pull images from Container Registry (no passwords)
- **Container Deployment**: Application runs in Docker containers
- **Dev Environment**: Configured for development workloads
- **Region**: All resources deployed in `westus3` for optimal AI model availability
- **Single Resource Group**: All resources organized in one resource group

## Parameters (main.bicep)

- `env`: environment short name (default `dev`)
- `location`: region (default `westus3`)
- `namePrefix`: resource name prefix (default `zava`)
- `containerImageTag`: image name:tag without registry (default `zavastorefront:latest`)
- `acrSku`: ACR SKU (`Basic` or `Standard`)
- `appServicePlanSku`: object `{ name, tier, size, capacity }` (default Basic B1)
- `appServiceAlwaysOn`: enable AlwaysOn on the Web App (default false)
- `logAnalyticsRetentionDays`: retention for Log Analytics

## Prerequisites

- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- Azure subscription
- Appropriate Azure permissions to create resources

## Deployment

### Build and push an image to ACR (cloud build):

```sh
az acr build -r <acrName> -t zavastorefront:<env> .
```

### Initialize AZD and provision:

```sh
azd init
azd provision --preview
azd up
```

## RBAC Configuration

The App Service is automatically granted the `AcrPull` role on the Container Registry, allowing it to pull container images without requiring registry credentials.

## Environment Variables

The following environment variables are automatically configured:

- `APPLICATIONINSIGHTS_CONNECTION_STRING`: For Application Insights integration
- `DOCKER_REGISTRY_SERVER_URL`: Container Registry URL
- `AZURE_OPENAI_ENDPOINT`: Azure OpenAI service endpoint

## Clean Up

To remove all deployed resources:

```bash
azd down
```