# Política de Segurança — workstation-devjoaolopes

A segurança dos seus dados locais, chaves de API e credenciais de ferramentas de IA é tratada com prioridade absoluta neste projeto.

---

## 🔒 Princípios de Segurança do Repositório

1. **Zero Segredos em Código**:
   - Nenhum token de autenticação, Personal Access Token (PAT) ou segredo de conta é commitado no controle de versão.
   - O arquivo `.env` é explicitamente bloqueado no `.gitignore`.
2. **Uso Seguro de Variáveis de Ambiente**:
   - O repositório fornece um `.env.example` apenas com a estrutura necessária.
   - Onde suportado (ex.: `opencode.json`), usamos interpolação em tempo de execução via referências `{env:VARIAVEL}`.
3. **Credenciais OAuth e Sessões**:
   - Tokens de sessão interativa gerados via OAuth (como nos MCPs do `notion` e `github`) residem exclusivamente no keychain ou storage local protegido de cada ferramenta em sua máquina.
4. **Isolamento de Máquina**:
   - Backups automáticos (`.bak`) são criados caso já existam arquivos de configuração em `$HOME` antes da criação de symlinks.

---

## 🚨 Reportando Vulnerabilidades

Se você identificar uma vulnerabilidade de segurança, possível vazamento de dados ou falha em scripts de automação:

- **Por favor, NÃO abra uma Issue pública.**
- Envie um relatório por e-mail diretamente para: **joaof.victor@hotmail.com** com o assunto `[SECURITY] workstation-devjoaolopes: Relato de Vulnerabilidade`.
- Inclua detalhes como:
  - Descrição da vulnerabilidade;
  - Passos detalhados para reprodução ou prova de conceito;
  - Possível impacto e sugestão de correção (caso aplicável).

Responderemos com a máxima agilidade para investigar, mitigar e publicar correções de segurança.
