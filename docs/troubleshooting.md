# Guia de Solução de Problemas (Troubleshooting) — workstation-devjoaolopes

Este guia reúne as dúvidas e cenários de erro mais comuns durante a instalação, execução ou uso diário do workstation.

---

## 🔍 1. Executando o Diagnóstico Primeiro

Antes de investigar erros manualmente, execute o script de diagnóstico do projeto:

```bash
make doctor
# ou
./scripts/doctor.sh
```

O relatório apontará imediatamente se alguma CLI ou dependência básica (Node.js, Python, Git, Google Chrome) está ausente ou desatualizada.

---

## 🛠️ 2. Erros Comuns e Como Resolver

### A. Permissão Negada ao Executar Scripts (`Permission denied`)
**Causa**: Os arquivos `.sh` podem ter perdido a flag de execução após clone ou manipulação em sistemas de arquivos específicos.  
**Solução**:
```bash
chmod +x scripts/*.sh scripts/lib/*.sh
```

---

### B. GitHub MCP acusando falta de token
**Sintoma**: Ao tentar interagir com issues ou PRs, o MCP retorna `Bad credentials` ou `Missing token`.  
**Solução**:
1. Verifique se o GitHub CLI está autenticado:
   ```bash
   gh auth status
   ```
   Se não estiver, execute `gh auth login`.
2. Caso prefira usar Personal Access Token, crie o arquivo `.env` a partir do `.env.example`:
   ```bash
   cp .env.example .env
   ```
   E defina a variável `GITHUB_PERSONAL_ACCESS_TOKEN=seu_token_aqui` com escopos `repo`, `read:org` e `workflow`. Em seguida, reexecute `./scripts/bootstrap.sh`.

---

### C. Notion MCP requer autenticação OAuth
**Sintoma**: Mensagem solicitando login ao chamar ferramentas do Notion.  
**Comportamento esperado**:
- O Notion MCP utiliza autenticação OAuth.
- Na **primeira vez** que você invocar o Notion dentro de uma sessão do Claude Code, AGY ou Codex, uma janela do navegador será aberta automaticamente para autorizar a integração com seu workspace do Notion.
- Uma vez autenticado, os tokens de sessão ficam salvos no armazenamento local seguro da ferramenta em sua máquina.

---

### D. Playwright MCP: Modo Headless vs. Extensão de Navegador
**Comportamento**:
- Por padrão, o Playwright MCP inicializa navegadores em modo headless/isolado.
- Se você deseja que os agentes de IA interajam diretamente com a aba ativa do seu navegador Chrome/Edge existente, instale a extensão oficial do Playwright MCP no seu navegador, copie o token gerado pela extensão e insira no `.env`:
  ```bash
  PLAYWRIGHT_MCP_EXTENSION_TOKEN=seu_token_da_extensao
  ```
  Depois rode `./scripts/bootstrap.sh` novamente.

---

### E. Chrome DevTools MCP falhando ao iniciar
**Causa**: O Google Chrome não está instalado na máquina ou não está acessível no caminho padrão.  
**Solução**:
- Certifique-se de que o Google Chrome está instalado na máquina.
- No macOS, o aplicativo deve estar em `/Applications/Google Chrome.app`.
- No Linux, certifique-se de que o binário `google-chrome` ou `chromium` está no `PATH`.

---

### F. Restaurando Backups de Configurações (`.bak`)
**Causa**: O bootstrap encontrou arquivos reais pré-existentes no seu `$HOME` e criou backups automáticos (`.bak`) antes de criar os symlinks.  
**Solução**:
- Se quiser reverter alguma configuração antiga, basta mover o arquivo de backup de volta:
  ```bash
  mv ~/.claude/settings.json.bak ~/.claude/settings.json
  ```
- Se quiser limpar todos os arquivos de backup gerados no repositório:
  ```bash
  make clean
  ```
