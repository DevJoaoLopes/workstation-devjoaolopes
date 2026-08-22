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

try "mcp github" codex mcp add github --url https://api.githubcopilot.com/mcp
try "login github (oauth)" codex mcp login github

try "mcp notion" codex mcp add notion --url https://mcp.notion.com/mcp
try "login notion (oauth)" codex mcp login notion

try "mcp playwright"      codex mcp add playwright -- npx @playwright/mcp@latest
try "mcp chrome-devtools" codex mcp add chrome-devtools -- npx chrome-devtools-mcp@latest

# Superpowers: a superpowers já publica um manifesto .codex-plugin, mas a
# sintaxe exata de `plugin marketplace add` pra um repo git de terceiro não
# foi validada linha a linha — trate como experimental.
warn "superpowers no codex é experimental — validar sintaxe de 'plugin marketplace add' se falhar"
try "marketplace add superpowers" codex plugin marketplace add superpowers https://github.com/obra/superpowers
try "plugin add superpowers"      codex plugin add superpowers@superpowers

# Skills avulsas (mattpocock/skills), vendorizadas em .agents/skills/.
# ~/.codex/skills/ existe e aceita skills do usuário; a descoberta automática
# desse formato específico ainda não foi confirmada ponta a ponta.
link_file ".agents/skills/grill-me" "$HOME/.codex/skills/grill-me"
link_file ".agents/skills/grilling" "$HOME/.codex/skills/grilling"
warn "grill-me/grilling linkados em ~/.codex/skills/ — confirme que o codex os reconhece (não validado)"

log "Codex CLI configurado. Rode 'codex mcp list' pra conferir status/auth."
