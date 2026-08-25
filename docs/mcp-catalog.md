# Catálogo de MCP Servers e Skills — workstation-devjoaolopes (V0)

Este catálogo documenta detalhadamente todos os MCP Servers, plugins e skills integrados à estação de trabalho, incluindo descrição, transporte, autenticação, capacidades e pré-requisitos.

---

## 🛠️ MCP Servers Integrados

### 1. Context7 (`context7`)
- **Descrição**: Fornece documentação atualizada, tipos e exemplos de bibliotecas, frameworks e SDKs modernos sob demanda para os modelos de IA.
- **Upstream**: [https://context7.com](https://context7.com/)
- **Transporte**: HTTP (`https://mcp.context7.com/mcp`)
- **Autenticação**: Nenhuma necessária
- **Capacidades**:
  - `resolve-library-id`: Resolve o identificador canônico de uma biblioteca.
  - `query-docs`: Realiza buscas semânticas na documentação oficial indexada.
- **Suporte por Ferramenta**:
  - Claude Code: Plugin oficial (`context7@claude-plugins-official`)
  - opencode: MCP remoto em `opencode.json`
  - Antigravity CLI: `agy mcp add context7 --type http https://mcp.context7.com/mcp`
  - Codex CLI: `codex mcp add context7 --url https://mcp.context7.com/mcp`

---

### 2. GitHub (`github`)
- **Descrição**: Integração oficial com a API do GitHub para gerenciar repositórios, issues, pull requests, revisões de código e buscas.
- **Upstream**: [@modelcontextprotocol/server-github](https://github.com/modelcontextprotocol/servers)
- **Transporte**: `stdio` (`npx -y @modelcontextprotocol/server-github`)
- **Autenticação**: Token de acesso (`GITHUB_PERSONAL_ACCESS_TOKEN` ou sessão do `gh auth token`)
- **Capacidades Principais**:
  - Leitura e criação de Pull Requests e Issues
  - Busca de repositórios e busca de código
  - Criação e modificação de arquivos via API do GitHub
- **Suporte por Ferramenta**:
  - Claude Code: `claude mcp add -s user github ...`
  - opencode: Bloco `mcp.github` com `{env:GITHUB_PERSONAL_ACCESS_TOKEN}`
  - Antigravity CLI: `agy mcp add --env ... github ...`
  - Codex CLI: `codex mcp add github --env ...`

---

### 3. Notion (`notion`)
- **Descrição**: Integração oficial com o Notion para busca de notas, leitura de documentos, edição de páginas e consulta a bancos de dados de conhecimento.
- **Upstream**: [https://mcp.notion.com/mcp](https://mcp.notion.com/mcp)
- **Transporte**: HTTP (`https://mcp.notion.com/mcp`)
- **Autenticação**: OAuth interativo (abre navegador na primeira utilização)
- **Capacidades Principais**:
  - Busca em páginas e bancos de dados (`notion-search`, `notion-fetch`)
  - Criação de anotações e documentos (`notion-create-pages`)
  - Gestão de comentários e reuniões (`notion-query-meeting-notes`)
- **Suporte por Ferramenta**:
  - Claude Code: `claude mcp add --transport http -s user notion ...`
  - opencode: Bloco `mcp.notion` em `opencode.json`
  - Antigravity CLI: `agy mcp add --type http notion ...`
  - Codex CLI: `codex mcp add notion ... && codex mcp login notion`

---

### 4. Playwright (`playwright`)
- **Descrição**: Automação avançada de navegadores headless ou conectados à janela ativa do usuário através da extensão oficial do Playwright MCP.
- **Upstream**: [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp)
- **Transporte**: `stdio` (`npx -y @playwright/mcp@latest`)
- **Autenticação**: Opcional (`PLAYWRIGHT_MCP_EXTENSION_TOKEN` para modo extensão de navegador)
- **Capacidades Principais**:
  - Navegação e renderização de páginas (`browser_navigate`, `browser_snapshot`)
  - Interação com elementos da UI (`browser_click`, `browser_fill_form`)
  - Capturas de tela e gravação de fluxos (`browser_take_screenshot`)
- **Suporte por Ferramenta**:
  - Claude Code: `claude mcp add -s user playwright ...`
  - opencode: Bloco `mcp.playwright` com `{env:PLAYWRIGHT_MCP_EXTENSION_TOKEN}`
  - Antigravity CLI: `agy mcp add playwright ...`
  - Codex CLI: `codex mcp add playwright ...`

---

### 5. Chrome DevTools (`chrome-devtools`)
- **Descrição**: Conexão em tempo real com instâncias em execução do Google Chrome para depuração, análise de performance e auditorias.
- **Upstream**: [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp)
- **Transporte**: `stdio` (`npx -y chrome-devtools-mcp@latest`)
- **Autenticação**: Nenhuma necessária
- **Pré-requisitos**: Google Chrome instalado na máquina local
- **Capacidades Principais**:
  - Inspeção de console e tráfego de rede (`list_console_messages`, `list_network_requests`)
  - Auditoria Lighthouse e análise de perfil (`lighthouse_audit`, `performance_analyze_insight`)
  - Captura de heap snapshots para diagnóstico de memória
- **Suporte por Ferramenta**:
  - Claude Code: `claude mcp add -s user chrome-devtools ...`
  - opencode: Bloco `mcp.chrome-devtools` em `opencode.json`
  - Antigravity CLI: `agy mcp add chrome-devtools ...`
  - Codex CLI: `codex mcp add chrome-devtools ...`

---

## 🧠 Frameworks de Skills e Plugins

### 1. Superpowers (`superpowers`)
- **Descrição**: Conjunto de habilidades metódicas de engenharia de software para agentes de IA.
- **Upstream**: [obra/superpowers](https://github.com/obra/superpowers)
- **Habilidades Incluídas**:
  - `brainstorming`: Exploração metódica de requisitos e design antes de codificar.
  - `test-driven-development`: Ciclos estritos de TDD (Red-Green-Refactor).
  - `systematic-debugging`: Investigação estruturada de falhas e causas-raiz.
  - `writing-plans` & `executing-plans`: Planejamento técnico e execução por etapas.
  - `requesting-code-review` & `receiving-code-review`: Revisão técnica rigorosa.

---

### 2. Grill Me (`grill-me` & `grilling`)
- **Descrição**: Skill desenvolvida por Matt Pocock para desafiar e "grelhar" decisões de arquitetura e planos através de entrevistas socráticas antes da implementação.
- **Upstream**: [mattpocock/skills](https://github.com/mattpocock/skills)
- **Estrutura**:
  - `grill-me`: Atalho de acionamento que direciona o harness para a skill base.
  - `grilling`: Motor da entrevista, estruturando árvores de decisões até esgotar premissas não validadas.
- **Vendorização**: Arquivos versionados em `.agents/skills/` com lockfile em `skills-lock.json`.
