## 📌 Descrição das Alterações

Por favor, inclua um resumo das mudanças propostas e qual problema ou melhoria este Pull Request endereça.

- **Tipo de Mudança**:
  - [ ] `feat:` Nova funcionalidade / MCP Server / Skill
  - [ ] `fix:` Correção de bug
  - [ ] `docs:` Atualização de documentação
  - [ ] `chore:` Tarefas de manutenção ou dependências
  - [ ] `refactor:` Refatoração de scripts

---

## 🔍 Checklist de Validação

- [ ] Se adicionou um novo MCP Server ou Skill:
  - [ ] Declarado em `mcps-generation.json`
  - [ ] Implementado nos scripts de setup correspondentes (`scripts/setup-*.sh`)
  - [ ] Documentado em `docs/mcp-catalog.md` e na tabela do `README.md`
- [ ] O comando `make check` passou sem erros de sintaxe de JSON, Bash ou Python.
- [ ] O comando `make doctor` / `./scripts/doctor.sh` foi executado e não apresentou inconsistências.
- [ ] Nenhuma chave de API ou segredo pessoal (`.env`, tokens) foi adicionado ao commit.
- [ ] Os commits seguem o padrão [Conventional Commits](https://www.conventionalcommits.org/).

---

## 🧪 Testes Realizados

Descreva como você testou suas alterações (ex.: testado em macOS Sonoma com Claude Code e agy).
