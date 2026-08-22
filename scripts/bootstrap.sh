#!/usr/bin/env bash
# Ponto de entrada único: detecta quais CLIs estão instaladas nesta máquina
# e chama o setup de cada uma. Seguro de rodar mais de uma vez (idempotente).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_ROOT
# shellcheck source=lib/common.sh
source "$REPO_ROOT/scripts/lib/common.sh"

if [ -f "$REPO_ROOT/.env" ]; then
  log "carregando $REPO_ROOT/.env"
  set -a
  # shellcheck source=/dev/null
  source "$REPO_ROOT/.env"
  set +a
fi

log "Iniciando bootstrap do workstation..."
echo

if has_cmd claude; then
  bash "$REPO_ROOT/scripts/setup-claude.sh"
else
  warn "claude não encontrado no PATH — pulando Claude Code (https://claude.com/claude-code)"
fi
echo

if has_cmd opencode; then
  bash "$REPO_ROOT/scripts/setup-opencode.sh"
else
  warn "opencode não encontrado no PATH — pulando opencode (https://opencode.ai)"
fi
echo

if has_cmd agy; then
  bash "$REPO_ROOT/scripts/setup-agy.sh"
else
  warn "agy não encontrado no PATH — pulando Antigravity CLI"
fi
echo

if has_cmd codex; then
  bash "$REPO_ROOT/scripts/setup-codex.sh"
else
  warn "codex não encontrado no PATH — pulando Codex CLI (npm install -g @openai/codex)"
fi
echo

log "Bootstrap concluído."
log "Revise os avisos acima — logins OAuth interativos precisam de ação manual na primeira vez que cada MCP for usado."
