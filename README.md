<!-- markdownlint-disable MD033 -->
# workstation-devjoaolopes

Configuração pessoal de ferramentas de IA para desenvolvimento — MCPs,
plugins e skills — versionada e reprodutível em qualquer máquina.

Cobre quatro ferramentas:

- **[Claude Code](https://claude.com/claude-code)**
- **[opencode](https://opencode.ai)**
- **agy** (Antigravity CLI, da Google)
- **[Codex CLI](https://github.com/openai/codex)** (OpenAI)

## Por quê

Cada uma dessas ferramentas guarda configuração global espalhada pelo
`$HOME` (`~/.claude`, `~/.config/opencode`, `~/.gemini`, `~/.codex`), em
formatos diferentes, com CLIs diferentes. Este repositório existe pra que
numa máquina zerada — ou pra qualquer outro dev que queira o mesmo ponto de
partida — dê pra reconstruir o mesmo setup com um comando, em vez de lembrar
de memória o que foi instalado onde.

## Estrutura

```
.
├── mcps-generation.json          # manifesto canônico: todo MCP/plugin/skill, o que é e como é instalado em cada ferramenta
├── .env.example                  # variáveis necessárias (só onde a ferramenta não suporta OAuth)
├── home/                         # espelha $HOME — cada arquivo aqui é symlinkado 1:1 pro lugar real
│   ├── .claude/settings.json     # → ~/.claude/settings.json
│   └── .config/opencode/opencode.json  # → ~/.config/opencode/opencode.json
├── .agents/skills/                # skills avulsas (mattpocock/skills) — formato "universal" cross-tool
│   ├── grill-me/                  # atalho que chama "grilling"
│   └── grilling/                  # a skill de verdade
├── skills-lock.json               # rastreia origem/versão das skills acima, pra `npx skills update`
├── docs/superpowers/specs/        # decisões de arquitetura registradas
└── scripts/
    ├── bootstrap.sh                # rode este — detecta o que está instalado e chama os setups abaixo
    ├── setup-claude.sh
    ├── setup-opencode.sh
    ├── setup-agy.sh
    └── setup-codex.sh
```

`.claude/settings.local.json` na raiz do repo é uma coisa **diferente**: é a
config de projeto deste próprio repositório (permissões do Claude Code
quando você trabalha aqui dentro), não faz parte do que é replicado pra
outras máquinas.

## Quick start numa máquina nova

1. Instale as ferramentas que for usar (pule as que não quiser):
   - Claude Code: `npm install -g @anthropic-ai/claude-code`
   - opencode: veja [opencode.ai](https://opencode.ai)
   - agy: CLI do Antigravity (Google)
   - Codex CLI: `npm install -g @openai/codex` (**não** o pacote `codex` sem
     escopo — é um projeto antigo não relacionado)
2. Clone este repositório.
3. `cp .env.example .env` e preencha só se algo pedir (ver [Secrets](#secrets)).
4. Rode:

   ```bash
   ./scripts/bootstrap.sh
   ```

   O script detecta quais das 4 CLIs existem no `PATH` e configura só essas
   — não precisa ter todas instaladas.
5. MCPs com OAuth (`github`, `notion`) abrem o navegador pra login na
   primeira vez que forem chamados dentro de uma sessão — isso não é
   automatizável, é uma ação manual de cada máquina.
6. Conectores de conta do Claude.ai (Gmail, Google Drive, Google Calendar,
   Wispr Flow) não são arquivo — não tem o que versionar. Conecte em
   [claude.ai/settings/connectors](https://claude.ai/settings/connectors) se
   quiser esses também.

O `bootstrap.sh` é seguro de rodar mais de uma vez: `mcp add` em algo que já
existe apenas avisa e segue, `plugin install` em algo já instalado é no-op, e
os symlinks fazem backup (`.bak`) de qualquer arquivo real que encontrarem no
caminho de destino antes de substituir.

## Inventário

| Recurso | O que é | Claude Code | opencode | agy | Codex CLI |
|---|---|---|---|---|---|
| [context7](https://context7.com/) | Docs de libs/frameworks sob demanda | plugin | config | `mcp add` | `mcp add` |
| [superpowers](https://github.com/obra/superpowers) | Skills: brainstorming, TDD, debugging, planos | plugin | plugin (git) | `plugin import` ⚠️ | `plugin marketplace` ⚠️ |
| [@modelcontextprotocol/server-github](https://github.com/modelcontextprotocol/servers) | Issues, PRs, repos, code search | `mcp add` + token/gh | config + token | `mcp add` + token/gh | `mcp add` + token/gh |
| notion | Busca e páginas do Notion | `mcp add` + OAuth | config | `mcp add` + OAuth | `mcp add` + `mcp login` |
| [playwright-mcp](https://github.com/microsoft/playwright-mcp) | Automação de browser (suporte a extensão) | `mcp add` | config | `mcp add` | `mcp add` |
| [chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | Debug/perf do Chrome ao vivo | `mcp add` | config | `mcp add` | `mcp add` |
| grill-me ([mattpocock/skills](https://github.com/mattpocock/skills)) | Skill de "grelhar" uma ideia antes de implementar | arquivo | universal, não verificado | universal, não verificado | arquivo, não verificado |
| statusline (agy) | Barra inferior essencial (branch, modelo, effort, ctx%, quota) | - | - | script nativo (`scripts/statusline.sh`) | - |

⚠️ = experimental nesta versão — o mecanismo existe mas não foi validado
ponta a ponta ainda. Veja `mcps-generation.json` (campo `status`) e o spec em
`docs/superpowers/specs/2026-08-22-repo-template-architecture-design.md`
pros detalhes e os fallbacks de cada um.

`chrome-devtools-mcp` exige o Google Chrome instalado — não tem como o
bootstrap resolver isso, é pré-requisito de máquina.

### Skills do mattpocock/skills (`grill-me`)

`grill-me` é só um atalho — o `SKILL.md` dele literalmente diz "Call the
Skill tool with 'grilling'". Por isso as duas skills (`grill-me` e
`grilling`) estão vendorizadas juntas em `.agents/skills/`; instalar só a
primeira deixa o atalho quebrado.

Pra trazer outra skill do mesmo pacote ou atualizar as existentes:

```bash
# nome da skill com ESPAÇO antes, não '=' — em modo agente
# `--skill=nome` é ignorado e instala as 36 skills do pacote inteiro
npx skills@latest add mattpocock/skills --skill nome-da-skill -y

# atualizar as já instaladas (usa o skills-lock.json)
npx skills@latest update
```

O instalador cria os arquivos reais em `.agents/skills/<nome>/` (convenção
cross-tool dele) e um symlink de conveniência em `.claude/skills/<nome>/`
pra esse próprio repositório — os `setup-*.sh` symlinkam a partir de
`.agents/skills/` pros diretórios globais de cada ferramenta.

## Como adicionar uma ferramenta nova

1. Adicione uma entrada em `mcps-generation.json` (`mcpServers` ou
   `pluginsAndSkills`) com a descrição, transporte/auth e o método de
   instalação por ferramenta.
2. Reflita isso no `scripts/setup-<ferramenta>.sh` correspondente — prefira
   sempre o CLI nativo da ferramenta (`<tool> mcp add`, `<tool> plugin
   install`) a editar um arquivo de config à mão. Só edite arquivo
   diretamente quando esse for o próprio mecanismo nativo da ferramenta (caso
   do opencode).
3. Atualize a tabela de inventário acima.
4. Rode o `setup-*.sh` da ferramenta afetada pra validar antes de commitar.

## Secrets

- **GitHub Token**: Os scripts tentam resolver automaticamente o token a partir da sessão local ativa do `gh` (`gh auth token`). Se não houver `gh` autenticado, defina `GITHUB_PERSONAL_ACCESS_TOKEN` no `.env`.
- **Playwright Extension**: Para conectar o Playwright MCP à aba ativa do navegador Chrome/Edge, configure `PLAYWRIGHT_MCP_EXTENSION_TOKEN` no `.env`.
- **OAuth (Notion)**: O login OAuth abre o navegador na primeira execução de cada ferramenta.

- `.env` nunca é commitado (está no `.gitignore`).
- Nenhum script grava token em texto plano fora do `.env`.
- Nenhum segredo de conta (OAuth tokens, sessões) é versionado — eles vivem
  no keychain/estado interno de cada ferramenta, fora deste repo.

## Status por ferramenta

- **Claude Code** — sólido. Todos os MCPs e plugins listados já rodam com suporte a stdio GitHub e Playwright com extensão.
- **opencode** — configurado via `home/.config/opencode/opencode.json` com variáveis interpoladas do ambiente.
- **Codex CLI** — comandos (`codex mcp add`, `codex plugin marketplace add/add`) configurados com suporte a token do GitHub.
- **agy** — MCPs configurados, suporte a extensão do Playwright e statusline customizada mínima integrada via `scripts/statusline.sh`.

## Fora de escopo (por enquanto)

- Agents/subagents customizados — havia um pacote genérico de 13 subagents
  duplicado em `.claude/`, `.codex/` e `.copilot/` que foi removido; decidir
  se volta curado ou fica de fora é uma decisão separada.
- Conectores de conta do Claude.ai (não são arquivo).
