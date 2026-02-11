# Copilot Custom Instructions for ZavaStorefront

## Project Overview
This is the **ZavaStorefront** web application — an ASP.NET Core 6.0 MVC app deployed as a Docker container to Azure App Service (Linux, Web App for Containers). Infrastructure is defined in Bicep (`infra/`) and provisioned with Azure Developer CLI (`azd`).

## Architecture
- **Runtime**: .NET 6, ASP.NET Core MVC
- **Container**: Multi-stage Docker build (`Dockerfile` at repo root)
- **Infrastructure**: Bicep modules in `infra/` — ACR, App Service Plan, Web App, Log Analytics, App Insights
- **CI/CD**: GitHub Actions workflow in `.github/workflows/container-appservice.yml`
- **Provisioning**: `azd up` using `azure.yaml` at repo root
- **Region**: westus3 | **Environment**: dev

## Conventions
- Bicep modules live in `infra/modules/` and are called from `infra/main.bicep`.
- Resource names follow the pattern `{namePrefix}{env}{resourceShort}` (e.g., `zavadevweb`).
- ACR names include a `uniqueString(resourceGroup().id)` suffix for global uniqueness.
- The Web App uses system-assigned managed identity with AcrPull role — no password-based ACR pulls.
- Tags must include `environment` and `workload`; the Web App also gets `azd-service-name: web`.

## Security Guidelines
- Never hardcode secrets, connection strings, or credentials in source code.
- Use managed identity for all Azure service-to-service authentication.
- ACR admin user must remain disabled (`adminUserEnabled: false`).
- App Insights connection strings are passed via app settings, not embedded in code.
- Review all PRs for secret leaks, insecure dependencies, and misconfigured RBAC.
- Container images should be scanned for vulnerabilities before deployment.

## When Generating Code
- Follow C# coding conventions (PascalCase for public members, camelCase for locals).
- Use `ILogger<T>` for logging, not `Console.WriteLine`.
- Bicep files should be parameterized — avoid hardcoded resource names or SKUs.
- GitHub Actions workflows should use `az acr build` (cloud builds), not local Docker.
