# GitHub Actions: Container build and App Service deploy (quickstart)

## Required secret

| Name | Type | How to create |
|------|------|---------------|
| `AZURE_CREDENTIALS` | Repository **Secret** | `az ad sp create-for-rbac --name "gh-zava" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID> --sdk-auth` — paste the full JSON output as the secret value. |

## Required variables

Add these as Repository **Variables** (Settings > Secrets and variables > Actions > Variables):

| Name | Example | Notes |
|------|---------|-------|
| `ACR_NAME` | `zavadevacr7hx...` | Short ACR name (from `azd provision` output `acrName`). |
| `ACR_LOGIN_SERVER` | `zavadevacr7hx....azurecr.io` | Full login server (from `azd provision` output `acrLoginServer`). |
| `WEBAPP_NAME` | `zavadevweb` | App Service name (from `azd provision` output `webAppName`). |
| `IMAGE_NAME` | `zavastorefront` | (Optional) Defaults to `zavastorefront` if not set. |

## How it works

1. Triggers on push to `main` or manual dispatch.
2. Logs into Azure with the service principal credentials.
3. Builds the container image **in the cloud** using `az acr build` (no local Docker needed).
4. Deploys the image to the App Service using `azure/webapps-deploy@v3`.

## Quick setup

1. Ensure infrastructure is provisioned (`azd up` or `azd provision`).
2. Create the service principal and store the JSON as `AZURE_CREDENTIALS` secret.
3. Set the four repository variables above.
4. Push to `main` (or run the workflow manually) to build and deploy.
