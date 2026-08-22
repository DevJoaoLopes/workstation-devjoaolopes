#!/usr/bin/env bash
# Configura o opencode a partir deste repositório.
#
# opencode não tem CLI de configuração — o próprio opencode.json hand-authored
# É o mecanismo nativo de config, então aqui só symlinkamos o arquivo.
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck source=lib/common.sh
source "$REPO_ROOT/scripts/lib/common.sh"

log "Configurando opencode..."

link_file "home/.config/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

# Resíduo conhecido: versões antigas do setup deixaram um opencode.jsonc
# vazio ao lado do opencode.json real. Remove se existir, pra não confundir.
jsonc="$HOME/.config/opencode/opencode.jsonc"
if [ -f "$jsonc" ] && [ ! -L "$jsonc" ]; then
  warn "removendo $jsonc (resíduo vazio, o opencode.json symlinkado é quem vale)"
  rm -f "$jsonc"
fi

log "opencode configurado."
log "github usa oauth:true agora (migrado de PAT) — confirme o login na primeira chamada ao MCP; se falhar, preencha GITHUB_PERSONAL_ACCESS_TOKEN no .env como fallback e adicione o header de volta no opencode.json."
