# Guia de Contribuição — workstation-devjoaolopes

Obrigado por se interessar em contribuir com este projeto! Este repositório é uma estação de trabalho e orquestrador de ferramentas de IA (MCPs, plugins, skills) versionado e reproduzível em qualquer máquina para **Claude Code**, **opencode**, **Antigravity CLI (agy)** e **Codex CLI**.

Este documento descreve as diretrizes para enviar melhorias, correções de bugs, novos MCP servers e novas skills.

---

## 🛠️ Ambiente de Desenvolvimento e Ferramentas

Para validar suas alterações localmente, você precisará de:

- **Git**
- **Bash** (v3.2 ou superior, padrão no macOS e Linux)
- **Python 3** (usado na validação de manifestos JSON)
- **Node.js** (>= 18) e **npm** / **npx** (usado pelos MCP servers baseados em stdio)
- *(Opcional)* **GitHub CLI (`gh`)** autenticado

### Diagnosticando o Ambiente

Antes de começar, você pode rodar o comando de diagnóstico do projeto:

```bash
make doctor
# ou diretamente:
./scripts/doctor.sh
```

---

## 📋 Como Adicionar um Novo MCP Server

Nosso repositório utiliza uma abordagem **orientada a manifesto**. Toda e qualquer ferramenta, MCP server ou plugin deve seguir rigorosamente este fluxo de 4 etapas:

1. **Manifesto Canônico (`mcps-generation.json`)**:
   - Adicione o objeto do MCP no array `mcpServers` com nome, descrição, fonte upstream, transporte (`stdio` ou `http`), parâmetros de autenticação e comando/método por ferramenta (`claude-code`, `opencode`, `agy`, `codex`).
2. **Scripts de Setup (`scripts/setup-*.sh`)**:
   - Reflita o comando correspondente em cada script.
   - Sempre prefira as CLIs nativas (`<tool> mcp add ...`) para Claude, AGY e Codex.
   - Para o `opencode`, declare em `home/.config/opencode/opencode.json` utilizando interpolação de variáveis de ambiente (`{env:VARIAVEL}`) caso haja segredos.
3. **Documentação Técnica (`docs/mcp-catalog.md` e `README.md`)**:
   - Documente o propósito da ferramenta, pré-requisitos (ex.: navegadores, tokens) e status de compatibilidade.
4. **Validação Local**:
   - Execute `make check` para garantir que o JSON é válido e os scripts Bash não possuem erros de sintaxe.

---

## 🧠 Como Adicionar ou Atualizar Skills

As skills universais são gerenciadas através do utilitário `@mattpocock/skills` e vendorizadas em `.agents/skills/`:

```bash
# Adicionar uma skill nova (use espaço após a flag --skill):
npx skills@latest add mattpocock/skills --skill nome-da-skill -y

# Atualizar as skills existentes respeitando o skills-lock.json:
npx skills@latest update
```

Após adicionar, certifique-se de configurar os devidos links nos scripts (`setup-claude.sh`, `setup-codex.sh`, etc.).

---

## 🧪 Validação e Testes Locais

Antes de abrir um Pull Request, execute os comandos de verificação:

```bash
# 1. Valida sintaxe de todos os JSONs, scripts Bash e Python:
make check

# 2. Executa o diagnóstico completo:
make doctor

# 3. Testa a execução do bootstrap (idempotente):
./scripts/bootstrap.sh
```

---

## 📝 Padrão de Mensagens de Commit

Adotamos a convenção de **[Conventional Commits](https://www.conventionalcommits.org/)**:

- `feat:` Adição de novo MCP server, skill ou funcionalidade de script.
- `fix:` Correção de bug em script de setup, symlink ou variável.
- `docs:` Alterações em documentação (`README.md`, `docs/`, `CONTRIBUTING.md`).
- `chore:` Atualizações de dependências, workflows de CI ou configurações gerais.
- `refactor:` Melhorias internas em scripts sem alteração de comportamento.

**Exemplos:**
- `feat(mcp): add context7 mcp server for dynamic documentation`
- `fix(claude): ensure portable skill symlink on fresh installs`
- `docs: update troubleshooting guide for oauth login flow`

---

## 🚀 Fluxo de Pull Request

1. Faça um Fork do repositório.
2. Crie uma branch para sua funcionalidade ou correção:
   ```bash
   git checkout -b feat/novo-mcp-exemplo
   ```
3. Realize suas alterações e execute `make check`.
4. Faça o commit das suas alterações seguindo o padrão de commits.
5. Faça o push para sua branch no GitHub:
   ```bash
   git push origin feat/novo-mcp-exemplo
   ```
6. Abra um Pull Request preenchendo o template padrão fornecido.

---

## 💬 Dúvidas ou Sugestões?

Sinta-se à vontade para abrir uma [Issue](https://github.com/DevJoaoLopes/workstation-devjoaolopes/issues) para discutir novas ideias, sugerir melhorias na orquestração ou reportar problemas!
