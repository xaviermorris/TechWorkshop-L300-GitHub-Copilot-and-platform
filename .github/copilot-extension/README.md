# ZavaStorefront Copilot Extension

Minimal Copilot Extension (GitHub App agent) for security and infrastructure help.

## Local testing

```bash
cd .github/copilot-extension
npm install
npm start
# Listening on http://localhost:3000
```

## Deploy to Azure

You can deploy this as a separate Azure App Service or Azure Function. Example with az CLI:

```bash
az webapp up --name zava-copilot-ext --runtime "NODE:20-lts" --sku B1
```

## Register as a GitHub App

1. Go to **Settings > Developer settings > GitHub Apps > New GitHub App**
2. Set the **Copilot Agent URL** to your deployed endpoint (e.g., `https://zava-copilot-ext.azurewebsites.net/`)
3. Enable **Copilot Chat** permission (Read & write)
4. Install the app on your repository
5. Users invoke via `@zava-security-agent` in Copilot Chat
