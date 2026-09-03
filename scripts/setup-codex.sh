#!/usr/bin/env bash
# Configura o Codex CLI a partir deste repositório.
#
# Requer o Codex CLI standalone (npm install -g @openai/codex ou
# brew install --cask codex) — não o binário vendorizado dentro da extensão
# do VS Code, que não fica no PATH.
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck source=lib/common.sh
source "$REPO_ROOT/scripts/lib/common.sh"

log "Configurando Codex CLI..."

try "mcp context7" codex mcp add context7 --url https://mcp.context7.com/mcp

gh_token="$(get_github_token)"
if [ -n "$gh_token" ]; then
  try "mcp github" codex mcp add github --env "GITHUB_PERSONAL_ACCESS_TOKEN=$gh_token" -- npx -y @modelcontextprotocol/server-github
else
  warn "GITHUB_PERSONAL_ACCESS_TOKEN não definido e 'gh auth token' indisponível — configure o token para o mcp github"
fi

try "mcp notion" codex mcp add notion --url https://mcp.notion.com/mcp
try "login notion (oauth)" codex mcp login notion

if [ -n "${PLAYWRIGHT_MCP_EXTENSION_TOKEN:-}" ]; then
  try "mcp playwright (extension)" codex mcp add playwright --env "PLAYWRIGHT_MCP_EXTENSION_TOKEN=$PLAYWRIGHT_MCP_EXTENSION_TOKEN" -- npx -y @playwright/mcp@latest --extension
else
  try "mcp playwright" codex mcp add playwright -- npx -y @playwright/mcp@latest
fi

try "mcp chrome-devtools" codex mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest

# Superpowers: `plugin marketplace add` aceita só a fonte (sem nome de
# marketplace) — `codex plugin marketplace add superpowers <url>` falha com
# "unexpected argument". O nome da marketplace também não é "superpowers":
# o repo obra/superpowers registra a marketplace como "superpowers-dev".
try "marketplace add obra/superpowers" codex plugin marketplace add "https://github.com/obra/superpowers"
try "plugin add superpowers"      codex plugin add superpowers@superpowers-dev

# Skills avulsas (mattpocock/skills), vendorizadas em .agents/skills/.
# ~/.codex/skills/ existe e aceita skills do usuário; a descoberta automática
# desse formato específico ainda não foi confirmada ponta a ponta.
link_file ".agents/skills/grill-me" "$HOME/.codex/skills/grill-me"
link_file ".agents/skills/grilling" "$HOME/.codex/skills/grilling"
warn "grill-me/grilling linkados em ~/.codex/skills/ — confirme que o codex os reconhece (não validado)"

log "Codex CLI configurado. Rode 'codex mcp list' pra conferir status/auth."
