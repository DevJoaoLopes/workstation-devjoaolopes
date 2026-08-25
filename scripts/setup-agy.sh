#!/usr/bin/env bash
# Configura o agy (Antigravity CLI) a partir deste repositório.
#
# Configura MCP servers e plugins.
# É idempotente (reexecutável sem efeitos colaterais indesejados).
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck source=lib/common.sh
source "$REPO_ROOT/scripts/lib/common.sh"

log "Configurando agy (Antigravity CLI)..."

# 1. MCP Servers
try "mcp context7" agy mcp add --type http context7 https://mcp.context7.com/mcp

gh_token="$(get_github_token)"
if [ -n "$gh_token" ]; then
  try "mcp github" agy mcp add --env "GITHUB_PERSONAL_ACCESS_TOKEN=$gh_token" github npx -y @modelcontextprotocol/server-github
else
  warn "GITHUB_PERSONAL_ACCESS_TOKEN não definido e 'gh auth token' indisponível — configure o token para o mcp github"
fi

try "mcp notion" agy mcp add --type http notion https://mcp.notion.com/mcp

if [ -n "${PLAYWRIGHT_MCP_EXTENSION_TOKEN:-}" ]; then
  try "mcp playwright (extension)" agy mcp add --env "PLAYWRIGHT_MCP_EXTENSION_TOKEN=$PLAYWRIGHT_MCP_EXTENSION_TOKEN" playwright npx -y @playwright/mcp@latest --extension
else
  try "mcp playwright" agy mcp add playwright npx -y @playwright/mcp@latest
fi

try "mcp chrome-devtools" agy mcp add chrome-devtools npx -y chrome-devtools-mcp@latest

# 2. Superpowers: experimental
warn "superpowers no agy é experimental — tentando 'agy plugin import claude'"
try "plugin import claude (superpowers)" agy plugin import claude

log "agy configurado. Rode 'agy mcp list' e 'agy plugin list' pra conferir."
