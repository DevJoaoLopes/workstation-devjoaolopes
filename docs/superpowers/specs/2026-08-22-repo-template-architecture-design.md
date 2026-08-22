# Arquitetura do Workstation Template — Design

**Data:** 2026-08-22
**Status:** Aprovado, em implementação nesta mesma branch (`feat/update`)

## Contexto

Este repositório (`workstation-devjoaolopes`) vira a fonte de verdade pessoal
de configuração de ferramentas de IA para desenvolvimento — hoje: Claude
Code, opencode, agy (Antigravity CLI) e Codex CLI. O objetivo é que, numa
máquina zerada, qualquer dev (ou o próprio dono, em outra máquina) consiga
reproduzir o mesmo conjunto de MCPs, plugins e skills.

Um audit prévio (não repetido aqui) mapeou o estado global de cada
ferramenta antes desta mudança — plugins/skills/MCPs já instalados em cada
uma, incluindo pontos de inconsistência (ex.: `github` usava OAuth no Claude
Code mas PAT no opencode).

## Escopo desta rodada

Decidido via brainstorming com o usuário:

1. **Todas as 4 ferramentas** ganham configuração de verdade nesta rodada
   (não só Claude Code + opencode, que já tinham algo funcionando).
2. **OAuth sempre que a ferramenta suportar**; token via env var só como
   fallback documentado onde a ferramenta não suporta OAuth.
3. **Documentação em português.**

Recursos a incluir (dados pelo usuário):

- [context7](https://context7.com/) — MCP de documentação de libs/frameworks
- [obra/superpowers](https://github.com/obra/superpowers) — framework de
  skills multi-harness (brainstorming, TDD, debugging sistemático, etc.)
- [github/github-mcp-server](https://github.com/github/github-mcp-server)
- [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp)
- [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp)
- `npx skills@latest add mattpocock/skills --skill=grill-me` — skill avulsa
  copiada como arquivo (não é MCP nem plugin)

Explicitamente fora de escopo nesta rodada: a pasta `agents/` (o pacote
genérico de 13 subagents removido no commit anterior desta branch fica em
aberto — decisão futura).

## Princípio arquitetural: native-first

A própria `superpowers` documenta isso em
`docs/porting-to-a-new-harness.md`: cada harness deve ser configurado através
do **próprio mecanismo de instalação dele** — nunca editando à mão um arquivo
de config que a ferramenta gera/gerencia. Adotamos o mesmo princípio aqui:

- Onde a ferramenta tem CLI de configuração (`claude mcp add`,
  `claude plugin install`, `agy mcp add`, `agy plugin import`,
  `codex mcp add`, `codex plugin add`), os scripts de setup chamam essa CLI.
- Onde a ferramenta **não** tem CLI e o próprio arquivo de config é
  hand-authored por natureza (`opencode.json`), o arquivo é versionado no
  repo e symlinkado — essa é a forma nativa de configurar o opencode.
- Nunca escrevemos diretamente em arquivos que a ferramenta gera/mistura com
  estado de sessão (ex.: `~/.claude.json`, `~/.codex/config.toml` já vêm
  cheios de dado gerado pela própria ferramenta — não são "nossos").

Alternativas consideradas e descartadas: um gerador único data-driven que
traduz um YAML canônico pra cada ferramenta (over-engineering pra 6 recursos
× 4 ferramentas — os CLIs são heterogêneos demais pra a abstração compensar
agora); documentação pura sem automação (não entrega "máquina zerada, um
comando").

## Estrutura de diretórios

```
.
├── README.md
├── .env.example
├── .gitignore
├── mcps-generation.json          # manifesto canônico dos MCPs/plugins/skills
├── home/                         # espelha $HOME — symlinkado 1:1 pelo bootstrap
│   ├── .claude/
│   │   └── settings.json
│   └── .config/
│       └── opencode/
│           └── opencode.json
├── skills/
│   └── grill-me/                 # skill copiada via `npx skills add`, fonte compartilhada
├── docs/superpowers/specs/       # specs deste processo de brainstorming
└── scripts/
    ├── bootstrap.sh              # detecta binários instalados e chama os setups
    ├── lib/common.sh
    ├── setup-claude.sh
    ├── setup-opencode.sh
    ├── setup-agy.sh
    └── setup-codex.sh
```

**Nota de implementação:** o design original em chat propunha espelhar
`.claude/` e `.config/` direto na raiz do repo (estilo GNU Stow puro). Ao
implementar, percebi um conflito real: `.claude/settings.json` na raiz do
repo tem duplo sentido no Claude Code — é tanto "o arquivo que vira
`~/.claude/settings.json`" quanto "o *project settings* deste próprio
repositório" (que já tem um `.claude/settings.local.json` genuinamente
project-scoped). Pra não colidir os dois conceitos, o conteúdo que mira
`$HOME` foi movido para `home/`, e a raiz `.claude/` do repo continua sendo
exclusivamente a configuração de projeto deste repositório.

## Matriz de suporte (ferramenta × recurso)

| Recurso | Claude Code | opencode | agy | codex |
|---|---|---|---|---|
| context7 | plugin `context7@claude-plugins-official` | `mcp.context7` remoto em `opencode.json` | `agy mcp add context7 --type http ...` | `codex mcp add context7 --url ...` |
| superpowers | plugin `superpowers@claude-plugins-official` | plugin git em `opencode.json` | `agy plugin import claude` (**validar**) | `codex plugin marketplace add` + `codex plugin add` (**validar sintaxe**) |
| github-mcp-server | `claude mcp add --transport http -s user` + OAuth automático | `mcp.github` remoto, `oauth: true` (migrado de PAT) | `agy mcp add --type http` | `codex mcp add --url` + `codex mcp login` |
| playwright-mcp | `claude mcp add -- npx @playwright/mcp@latest` | `mcp.playwright` local | `agy mcp add playwright npx ...` | `codex mcp add -- npx ...` |
| chrome-devtools-mcp | `claude mcp add -- npx chrome-devtools-mcp@latest` | `mcp.chrome-devtools` local | `agy mcp add chrome-devtools npx ...` | `codex mcp add -- npx ...` |
| grill-me (skill) | arquivo em `~/.claude/skills/grill-me` | sem convenção nativa (**não suportado**) | sem convenção nativa (**não suportado**) | arquivo em `~/.codex/skills/grill-me` (**validar**) |

`notion` não estava na lista original do usuário mas já estava configurado
(Claude Code + opencode) antes desta mudança — mantido como carry-over no
manifesto e estendido para agy/codex por consistência.

## Manifesto (`mcps-generation.json`)

Fonte de verdade legível por humano e por agente. Não é consumido por um
gerador automático — é a referência que qualquer sessão futura (minha ou de
outro dev) lê antes de adicionar uma ferramenta nova, pra manter o padrão.
Cada entrada documenta: descrição, transporte/auth, e — por ferramenta — o
método usado (`plugin`, `config`, `cli`, `file`) e o comando ou caminho
exato.

## Secrets

`.env.example` documenta variáveis **só onde a ferramenta não suporta
OAuth nativo** (hoje, isso é só o fallback do github no opencode, comentado
por padrão). `.env` real é gitignored; `scripts/bootstrap.sh` o carrega
antes de chamar os setups. Nenhum script grava token em texto plano fora do
`.env`.

## Riscos assumidos / itens para validar na implementação

1. `agy plugin import claude` pode não trazer a `superpowers` corretamente —
   sem manifesto `.antigravity-plugin` dedicado no repo upstream, é
   experimental. Fallback: clonar o repo localmente e usar
   `agy plugin install <dir>`.
2. Sintaxe exata de `codex plugin marketplace add` para apontar num repo git
   de terceiro não foi confirmada linha a linha — o comando no script está
   marcado para revisão.
3. Migrar o `github` do opencode de PAT para `oauth: true` pressupõe que o
   fluxo OAuth do opencode funciona pra esse servidor — testar após rodar o
   setup.
4. Suporte da skill avulsa (`grill-me`) em opencode/agy não está confirmado;
   tratado como não suportado por ora.
5. O Codex CLI standalone (`npm install -g @openai/codex`) precisa estar
   instalado — nesta máquina, hoje, só existe o binário vendorizado dentro da
   extensão do VS Code, que não fica no `PATH`.

## Atualização pós-implementação

Achados reais ao rodar os comandos (não estavam previstos no design original):

- `npx skills@latest add mattpocock/skills --skill=grill-me` (com `=`, como
  o usuário passou originalmente) é **ignorado** pelo parser do CLI em modo
  agente e instala as 36 skills do pacote inteiro. A forma correta é com
  espaço: `--skill grill-me`. Confirmado testando os dois.
- O instalador não usa a pasta `skills/` do design original — ele tem
  convenção própria, `.agents/skills/<nome>/`, que ele mesmo descreve como
  "universal" (lida nativamente por Antigravity, Antigravity CLI, Codex,
  Gemini CLI, GitHub Copilot, OpenCode, Warp, Windsurf) mais um symlink de
  conveniência pra Claude Code. Isso muda a matriz de suporte: opencode e
  agy passam de "não suportado" pra "universal, não verificado" (o formato
  existe, mas não testamos se cada ferramenta realmente descobre
  `.agents/skills/` fora deste repositório).
- `grill-me` é um atalho ("Call the Skill tool with 'grilling'") sem
  conteúdo próprio — instalar só ele deixa a skill quebrada. Instalamos
  `grilling` (a skill de verdade) junto, fora do pedido literal original,
  porque sem ela o que foi pedido não funciona.
- Também descoberto: escrever em qualquer arquivo cujo caminho relativo bate
  com `.claude/settings.json` é bloqueado pelo classificador de permissões
  do Claude Code, mesmo dentro de `home/`. Ficou pendente — ver conversa.

## Fora de escopo

- Conteúdo de `agents/` (pacote genérico de subagents) — decisão adiada.
- Conectores de conta do Claude.ai (Gmail, Drive, Calendar, Wispr Flow) — não
  são arquivo, vivem na conta; documentados no README como passo manual.
