const express = require("express");

const app = express();
app.use(express.json());

const SYSTEM_PROMPT = `You are the ZavaStorefront security and infrastructure assistant.
You help developers with:
- Azure infrastructure questions (Bicep, App Service, ACR, App Insights)
- Security best practices (managed identity, no hardcoded secrets, ACR admin disabled)
- CI/CD pipeline guidance (GitHub Actions, az acr build, deployments)
- .NET 6 / ASP.NET Core MVC code guidance

Project conventions:
- Infra is in infra/ using Bicep modules, provisioned with azd
- Container builds use az acr build (cloud builds, no local Docker)
- Web App uses system-assigned managed identity with AcrPull role
- Region: westus3, Environment: dev
- Never expose secrets in code or logs`;

// Copilot Extension endpoint — receives chat messages, returns streaming response
app.post("/", async (req, res) => {
  const { messages } = req.body;

  // Build the payload to forward to an LLM or handle directly
  const userMessage =
    messages && messages.length > 0
      ? messages[messages.length - 1].content
      : "";

  // Return a simple SSE-streamed response
  // In production, you'd call an LLM API (Azure OpenAI, etc.) with SYSTEM_PROMPT + messages
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");

  const reply = generateReply(userMessage);

  // Stream as Copilot expects: server-sent events with "data:" prefix
  res.write(
    `data: ${JSON.stringify({
      choices: [{ delta: { content: reply }, index: 0 }],
    })}\n\n`
  );
  res.write("data: [DONE]\n\n");
  res.end();
});

function generateReply(message) {
  const lower = message.toLowerCase();

  if (lower.includes("secret") || lower.includes("credential")) {
    return "Never hardcode secrets. Use Azure Managed Identity for service-to-service auth. Store app settings in App Service configuration or Azure Key Vault. ACR admin user must stay disabled.";
  }
  if (lower.includes("deploy") || lower.includes("pipeline")) {
    return "Use `az acr build` for cloud container builds (no local Docker). The workflow in `.github/workflows/container-appservice.yml` handles build + deploy. Set `AZURE_CREDENTIALS` secret and `ACR_NAME`, `ACR_LOGIN_SERVER`, `WEBAPP_NAME` as repo variables.";
  }
  if (lower.includes("bicep") || lower.includes("infra")) {
    return "Infrastructure is in `infra/main.bicep` with modules in `infra/modules/`. All resources are parameterized. Run `azd up` to provision + deploy, or `azd provision` for infra only.";
  }

  return `I'm the ZavaStorefront assistant. I can help with:\n- **Security**: secrets management, managed identity, dependency scanning\n- **Infrastructure**: Bicep modules, ACR, App Service, App Insights\n- **CI/CD**: GitHub Actions, container builds, deployments\n\nWhat would you like to know?`;
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Copilot Extension listening on port ${PORT}`);
});
