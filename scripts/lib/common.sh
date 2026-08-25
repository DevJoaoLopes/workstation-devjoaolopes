#!/usr/bin/env bash
# Helpers compartilhados pelos scripts de setup. Não é executado diretamente.

log()  { printf '\033[1;34m[bootstrap]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[bootstrap]\033[0m %s\n' "$1" >&2; }
err()  { printf '\033[1;31m[bootstrap]\033[0m %s\n' "$1" >&2; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# link_file <caminho-relativo-no-repo> <destino-absoluto>
# Cria (ou substitui) um symlink apontando pro arquivo do repo. Se já existir
# um arquivo real (não-symlink) no destino, faz backup em vez de sobrescrever.
link_file() {
  local src="$REPO_ROOT/$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    err "fonte não encontrada: $src"
    return 1
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    warn "$dest já existe e não é um symlink — backup em $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  ln -sfn "$src" "$dest"
  log "linkado $dest -> $src"
}

# Roda um comando de setup sem derrubar o script inteiro se falhar (ex.:
# recurso já configurado antes). Sempre avisa em caso de falha.
try() {
  local desc="$1"; shift
  if "$@"; then
    log "ok: $desc"
  else
    warn "falhou (pode já estar configurado): $desc"
  fi
}

# get_github_token
# Retorna o token do GitHub a partir de GITHUB_PERSONAL_ACCESS_TOKEN ou do `gh auth token`
get_github_token() {
  if [ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
    echo "$GITHUB_PERSONAL_ACCESS_TOKEN"
  elif has_cmd gh; then
    gh auth token 2>/dev/null || true
  fi
}


