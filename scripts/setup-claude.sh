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
try "mcp github"          claude mcp add --transport http -s user github https://api.githubcopilot.com/mcp
try "mcp notion"          claude mcp add --transport http -s user notion https://mcp.notion.com/mcp
try "mcp playwright"      claude mcp add -s user playwright -- npx @playwright/mcp@latest
try "mcp chrome-devtools" claude mcp add -s user chrome-devtools -- npx chrome-devtools-mcp@latest

# Skills avulsas (mattpocock/skills), já vendorizadas em .agents/skills/ —
# ver "Como atualizar a skill grill-me" no README pra trazer versões novas.
# grill-me é só um atalho que chama "grilling"; os dois precisam estar
# presentes pro atalho funcionar.
link_file ".agents/skills/grill-me" "$HOME/.claude/skills/grill-me"
link_file ".agents/skills/grilling" "$HOME/.claude/skills/grilling"

log "Claude Code configurado."
log "github e notion pedem login OAuth no navegador na primeira vez que forem usados numa sessão."
