#!/usr/bin/env bash
# Diagnóstico completo do ambiente do workstation de IA
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Cores
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[34m"
CYAN="\033[36m"

pass() { printf "  ${GREEN}✔${RESET} %s\n" "$1"; }
warn() { printf "  ${YELLOW}▲${RESET} %s\n" "$1"; }
fail() { printf "  ${RED}✖${RESET} %s\n" "$1"; }
info() { printf "  ${CYAN}ℹ${RESET} %s\n" "$1"; }
header() { printf "\n${BOLD}${BLUE}=== %s ===${RESET}\n" "$1"; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

echo
printf "${BOLD}🩺 Diagnóstico do Workstation de IA (DevJoaoLopes V0)${RESET}\n"
printf "${CYAN}Verificando pré-requisitos, CLIs instaladas e symlinks...${RESET}\n"

# 1. Sistema Operacional e Shell
header "1. Sistema Operacional & Ambiente"
OS="$(uname -s)"
ARCH="$(uname -m)"
info "SO detectado: $OS ($ARCH)"

if has_cmd git; then
  GIT_VER="$(git --version | head -n1)"
  pass "Git: $GIT_VER"
else
  fail "Git não encontrado no PATH"
fi

if has_cmd python3; then
  PY_VER="$(python3 --version 2>&1)"
  pass "Python 3: $PY_VER"
else
  fail "Python 3 não encontrado (necessário para validações de integridade)"
fi

if has_cmd node; then
  NODE_VER="$(node -v)"
  NODE_MAJOR="$(echo "$NODE_VER" | sed 's/v//' | cut -d. -f1)"
  if [ "$NODE_MAJOR" -ge 18 ]; then
    pass "Node.js: $NODE_VER (>= v18)"
  else
    warn "Node.js: $NODE_VER (Recomendado >= v18 para suporte pleno a MCPs)"
  fi
else
  fail "Node.js não encontrado no PATH"
fi

if has_cmd npm; then
  NPM_VER="$(npm -v)"
  pass "npm / npx: v$NPM_VER"
else
  fail "npm não encontrado no PATH"
fi

if has_cmd jq; then
  pass "jq: instalado"
else
  info "jq: não encontrado (opcional, útil para manipulação de JSON)"
fi

# 2. Autenticação e Credenciais
header "2. Autenticação & Segredos"
if has_cmd gh; then
  if gh auth status >/dev/null 2>&1; then
    pass "GitHub CLI (gh): instalado e autenticado"
  else
    warn "GitHub CLI (gh): instalado, mas não autenticado ('gh auth login' recomendado)"
  fi
else
  warn "GitHub CLI (gh): não instalado (configure GITHUB_PERSONAL_ACCESS_TOKEN no .env)"
fi

if [ -f "$REPO_ROOT/.env" ]; then
  pass "Arquivo .env presente no repositório"
else
  info "Arquivo .env não encontrado (utilizando .env.example como modelo caso precise de tokens)"
fi

# 3. Pré-requisitos de MCPs
header "3. Pré-requisitos de MCPs"
CHROME_INSTALLED=0
if [ "$OS" = "Darwin" ]; then
  if [ -d "/Applications/Google Chrome.app" ] || [ -d "$HOME/Applications/Google Chrome.app" ]; then
    CHROME_INSTALLED=1
  fi
elif has_cmd google-chrome || has_cmd chromium || has_cmd google-chrome-stable; then
  CHROME_INSTALLED=1
fi

if [ "$CHROME_INSTALLED" -eq 1 ]; then
  pass "Google Chrome detectado (necessário para chrome-devtools MCP)"
else
  warn "Google Chrome não detectado no caminho padrão (chrome-devtools MCP pode requerer instalação manual)"
fi

# 4. CLIs de IA Detectadas
header "4. CLIs de Inteligência Artificial"
CLIS_FOUND=0

if has_cmd claude; then
  CLIS_FOUND=$((CLIS_FOUND + 1))
  pass "Claude Code (claude): instalado ($(claude --version 2>/dev/null || echo 'versão ativa'))"
else
  warn "Claude Code: não encontrado no PATH (npm i -g @anthropic-ai/claude-code)"
fi

if has_cmd opencode; then
  CLIS_FOUND=$((CLIS_FOUND + 1))
  pass "opencode: instalado ($(opencode --version 2>/dev/null || echo 'versão ativa'))"
else
  warn "opencode: não encontrado no PATH (https://opencode.ai)"
fi

if has_cmd agy; then
  CLIS_FOUND=$((CLIS_FOUND + 1))
  pass "Antigravity CLI (agy): instalado"
else
  warn "Antigravity CLI (agy): não encontrado no PATH"
fi

if has_cmd codex; then
  CLIS_FOUND=$((CLIS_FOUND + 1))
  pass "Codex CLI (codex): instalado"
else
  warn "Codex CLI: não encontrado no PATH (npm i -g @openai/codex)"
fi

# 5. Verificação de Symlinks no $HOME
header "5. Status de Configurações no \$HOME"

check_link() {
  local target="$1"
  local name="$2"
  if [ -L "$target" ]; then
    pass "$name: linkado para $(readlink "$target")"
  elif [ -f "$target" ]; then
    warn "$name: arquivo existente, mas não é um symlink gerenciado por este repo"
  else
    info "$name: não configurado ainda (será criado ao rodar ./scripts/bootstrap.sh)"
  fi
}

check_link "$HOME/.claude/settings.json" "Claude Code settings"
check_link "$HOME/.config/opencode/opencode.json" "opencode config"
check_link "$HOME/.claude/skills/grill-me" "Claude Code skill: grill-me"

echo
header "Resumo da Auditoria"
if [ "$CLIS_FOUND" -gt 0 ]; then
  printf "  ${GREEN}Pronto para uso!${RESET} Foram detectadas ${BOLD}%d${RESET} CLI(s) de IA prontas para orquestração.\n" "$CLIS_FOUND"
  printf "  Execute ${CYAN}./scripts/bootstrap.sh${RESET} (ou ${CYAN}make setup${RESET}) para aplicar as configurações.\n\n"
else
  printf "  ${YELLOW}Nenhuma CLI de IA foi detectada no PATH.${RESET}\n"
  printf "  Instale pelo menos uma das ferramentas acima para executar o bootstrap.\n\n"
fi
