# ZavaStorefront Infrastructure

This folder contains the Bicep templates used by Azure Developer CLI (AZD) to provision the ZavaStorefront dev environment in a single resource group in westus3.

## Provision

```bash
azd provision
```

## Build and push the container image without local Docker

Use Azure Container Registry cloud builds to build the Docker image in Azure:

```bash
az acr build --registry <acr-name> --image zavastorefront:latest .
```

After the image is pushed, the App Service will pull the image using its managed identity (AcrPull role) and start the container.

## Outputs

The deployment outputs include the ACR name/login server, App Service name, and the Microsoft Foundry endpoint for application configuration.
