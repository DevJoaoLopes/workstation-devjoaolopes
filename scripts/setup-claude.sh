#!/usr/bin/env bash
# Configura o Claude Code a partir deste repositório.
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck source=lib/common.sh
source "$REPO_ROOT/scripts/lib/common.sh"

log "Configurando Claude Code..."

# settings.json global (model, plugins habilitados, etc.)
link_file "home/.claude/settings.json" "$HOME/.claude/settings.json"

# Plugins — o marketplace oficial (claude-plugins-official) já vem
# auto-instalado pelo próprio Claude Code, não precisa adicionar à mão.
for plugin in ralph-loop code-review frontend-design superpowers context7 feature-dev rust-analyzer-lsp; do
  try "plugin $plugin" claude plugin install -y "${plugin}@claude-plugins-official"
done

# MCP servers que não vêm embutidos em nenhum plugin (escopo "user" = global)
gh_token="$(get_github_token)"
if [ -n "$gh_token" ]; then
  try "mcp github" claude mcp add -s user github -e "GITHUB_PERSONAL_ACCESS_TOKEN=$gh_token" -- npx -y @modelcontextprotocol/server-github
else
  warn "GITHUB_PERSONAL_ACCESS_TOKEN não definido e 'gh auth token' indisponível — configure o token para o mcp github"
fi

try "mcp notion" claude mcp add --transport http -s user notion https://mcp.notion.com/mcp

if [ -n "${PLAYWRIGHT_MCP_EXTENSION_TOKEN:-}" ]; then
  try "mcp playwright (extension)" claude mcp add -s user playwright -e "PLAYWRIGHT_MCP_EXTENSION_TOKEN=$PLAYWRIGHT_MCP_EXTENSION_TOKEN" -- npx -y @playwright/mcp@latest --extension
else
  try "mcp playwright" claude mcp add -s user playwright -- npx -y @playwright/mcp@latest
fi

try "mcp chrome-devtools" claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest

# Skills avulsas (mattpocock/skills), já vendorizadas em .agents/skills/ —
# ver "Como atualizar a skill grill-me" no README pra trazer versões novas.
# grill-me é só um atalho que chama "grilling"; os dois precisam estar
# presentes pro atalho funcionar.
link_file ".agents/skills/grill-me" "$HOME/.claude/skills/grill-me"
link_file ".agents/skills/grilling" "$HOME/.claude/skills/grilling"

log "Claude Code configurado."
