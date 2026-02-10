# Azure Infrastructure for ZavaStorefront

This directory contains the Azure infrastructure as code (IaC) using Bicep templates for the ZavaStorefront web application.

## Architecture Overview

The infrastructure includes:

- **Azure Container Registry**: For storing Docker container images
- **Azure App Service (Linux)**: Hosting the containerized .NET application
- **Application Insights**: For monitoring and diagnostics
- **Log Analytics Workspace**: For centralized logging
- **Azure OpenAI (Microsoft Foundry)**: For AI capabilities with GPT and Phi models

## Key Features

- **RBAC-based Authentication**: App Service uses managed identity to pull images from Container Registry (no passwords)
- **Container Deployment**: Application runs in Docker containers
- **Dev Environment**: Configured for development workloads
- **Region**: All resources deployed in `westus3` for optimal AI model availability
- **Single Resource Group**: All resources organized in one resource group

## Prerequisites

- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- Azure subscription
- Appropriate Azure permissions to create resources

## Deployment

### Initialize the environment

```bash
azd init
```

### Provision infrastructure

```bash
azd provision
```

### Deploy application

```bash
azd deploy
```

### Full deployment (provision + deploy)

```bash
azd up
```

## Resources Created

1. **Resource Group**: `rg-{environmentName}`
2. **Container Registry**: `cr{uniqueToken}` (with admin disabled)
3. **App Service Plan**: `plan-{uniqueToken}` (Linux, Basic tier)
4. **App Service**: `app-{uniqueToken}` (with system-assigned managed identity)
5. **Application Insights**: `appi-{uniqueToken}`
6. **Log Analytics Workspace**: `log-{uniqueToken}`
7. **Azure OpenAI**: `cog-{uniqueToken}` (with GPT-4 and Phi-3 deployments)

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
