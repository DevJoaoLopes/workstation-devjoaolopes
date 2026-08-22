#!/usr/bin/env bash
# Configura o agy (Antigravity CLI) a partir deste repositório.
#
# agy não tem um arquivo de config pra symlinkar — tudo passa pela CLI
# (agy mcp add / agy plugin ...), então este script é só uma sequência de
# comandos nativos, idempotente (agy mcp add com o mesmo nome atualiza).
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck source=lib/common.sh
source "$REPO_ROOT/scripts/lib/common.sh"

log "Configurando agy (Antigravity CLI)..."

try "mcp context7"        agy mcp add --type http context7 https://mcp.context7.com/mcp
try "mcp github"          agy mcp add --type http github https://api.githubcopilot.com/mcp
try "mcp notion"          agy mcp add --type http notion https://mcp.notion.com/mcp
try "mcp playwright"      agy mcp add playwright npx -y @playwright/mcp@latest
try "mcp chrome-devtools" agy mcp add chrome-devtools npx -y chrome-devtools-mcp@latest

# Superpowers: experimental. `agy plugin import claude` tenta trazer os
# plugins já instalados no Claude Code local (inclusive superpowers). Não há
# manifesto dedicado de antigravity no repo upstream ainda — se isso falhar,
# a alternativa é clonar https://github.com/obra/superpowers e rodar
# `agy plugin install <diretório clonado>` manualmente.
warn "superpowers no agy é experimental — tentando 'agy plugin import claude'"
try "plugin import claude (superpowers)" agy plugin import claude

log "agy configurado (MCPs). Rode 'agy mcp list' e 'agy plugin list' pra conferir."
log "grill-me: agy não tem convenção nativa de skill avulsa — não instalado aqui."
