# Copilot Coding Agent Instructions

You are a coding agent working on the ZavaStorefront repository. Follow these rules when implementing issues and creating PRs.

## General Rules
- Read the issue description fully before writing any code.
- Make minimal, focused changes — do not refactor unrelated code.
- Ensure `dotnet build` passes in the `src/` directory before committing.
- Write clear commit messages that reference the issue number (e.g., `fix: resolve cart total calculation #12`).

## Project Structure
- `src/` — ASP.NET Core 6.0 MVC application (Controllers, Models, Services, Views)
- `infra/` — Bicep infrastructure-as-code (modules in `infra/modules/`)
- `.github/workflows/` — CI/CD pipelines
- `Dockerfile` — Multi-stage container build at repo root

## Security Rules (CRITICAL)
- NEVER commit secrets, API keys, connection strings, or credentials.
- NEVER disable ACR admin user or weaken managed identity configuration.
- NEVER add `--skip-ssl-validation` or disable certificate checks.
- NEVER introduce `eval()`, `Process.Start()` with unsanitized input, or SQL injection vectors.
- If a dependency is added, verify it is from a trusted source and actively maintained.
- All new endpoints must validate input and return appropriate error codes.

## Infrastructure Changes
- Bicep changes go in `infra/modules/` as separate module files, called from `infra/main.bicep`.
- Parameterize all resource names, SKUs, and regions — no hardcoded values.
- Include `tags` on every Azure resource.
- Test with `az bicep build` before committing.

## Testing
- Run `dotnet build` in `src/` to validate C# changes.
- For Bicep changes, run `az bicep build -f infra/main.bicep` to validate.
