# ZavaStorefront Deployment Guide

## Overview

This guide explains how to deploy the ZavaStorefront application to Azure using Azure Developer CLI (azd).

## Prerequisites

- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- Azure subscription
- Azure CLI (optional, for manual operations)

## Infrastructure Components

The deployment creates the following Azure resources in the **westus3** region:

1. **Resource Group** - Container for all resources
2. **Azure Container Registry** - Stores Docker images
3. **Azure App Service (Linux)** - Hosts the containerized application
4. **App Service Plan** - Compute resources for App Service
5. **Application Insights** - Application monitoring and diagnostics
6. **Log Analytics Workspace** - Centralized logging
7. **Azure OpenAI** - AI capabilities with GPT-4 and Phi-3 models

### Key Features

- **RBAC Authentication**: App Service uses managed identity to pull images (no passwords)
- **Container Deployment**: Application runs in Docker containers
- **Dev Environment**: Optimized for development workloads
- **Monitoring**: Application Insights integrated for observability

## Quick Start

### 1. Install Azure Developer CLI

**macOS/Linux:**
```bash
curl -fsSL https://aka.ms/install-azd.sh | bash
```

**Windows:**
```powershell
winget install microsoft.azd
```

### 2. Login to Azure

```bash
azd auth login
```

### 3. Initialize the Environment

```bash
azd init
```

When prompted:
- Environment name: Choose a unique name (e.g., `zavastorefrontdev`)
- Subscription: Select your Azure subscription

### 4. Deploy Everything

```bash
azd up
```

This command will:
1. Provision all Azure infrastructure
2. Build the Docker container
3. Push the container to Azure Container Registry
4. Deploy the container to App Service

## Manual Steps

If you prefer to run steps individually:

### Provision Infrastructure Only

```bash
azd provision
```

### Deploy Application Only

```bash
azd deploy
```

## Accessing Your Application

After deployment, azd will output the application URL:

```
APP_SERVICE_URL: https://app-{uniquetoken}.azurewebsites.net
```

Visit this URL in your browser to see your deployed application.

## Monitoring

Access Application Insights to monitor your application:

1. Go to the Azure Portal
2. Navigate to your resource group
3. Open the Application Insights resource
4. View metrics, logs, and performance data

## Azure OpenAI Access

The deployment includes Azure OpenAI with:
- **GPT-4** deployment
- **Phi-3** deployment

To use these models in your application, you can retrieve the endpoint and keys from the Azure Portal or use the outputs from the deployment.

## Cleanup

To remove all deployed resources:

```bash
azd down
```

This will delete the resource group and all contained resources.

## Troubleshooting

### Issue: Deployment fails during container build

**Solution**: Ensure the Dockerfile is properly configured and all dependencies are available.

### Issue: Cannot access Application Insights

**Solution**: Check that the connection string is properly set in the App Service configuration.

### Issue: App Service cannot pull images from Container Registry

**Solution**: Verify that the managed identity has the AcrPull role assigned (this should be automatic).

## Additional Resources

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [Application Insights Documentation](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
