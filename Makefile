.PHONY: help setup doctor check validate clean

SHELL := /usr/bin/env bash

define VALIDATE_JSON_PY
import os, json, sys
errors = 0
for root, dirs, files in os.walk('.'):
    if '.git' in root or 'node_modules' in root:
        continue
    for f in files:
        if f.endswith('.json'):
            p = os.path.join(root, f)
            try:
                with open(p, 'r', encoding='utf-8') as fp:
                    json.load(fp)
                print(f'  ✅ {p}')
            except Exception as e:
                print(f'  ❌ {p}: {e}', file=sys.stderr)
                errors += 1
if errors > 0:
    sys.exit(1)
endef
export VALIDATE_JSON_PY

help: ## Exibe este menu de ajuda
	@echo "Comandos disponíveis no workstation-devjoaolopes:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Executa o bootstrap do workstation (idempotente)
	@./scripts/bootstrap.sh

doctor: ## Executa o diagnóstico completo de ambiente e ferramentas
	@./scripts/doctor.sh

check: validate ## Valida sintaxe de JSONs e scripts Bash

validate: ## Executa validação estática de integridade do código
	@echo "🔍 Validando arquivos JSON..."
	@python3 -c "$$VALIDATE_JSON_PY"
	@echo "🔍 Validando sintaxe de scripts Bash..."
	@for s in scripts/lib/*.sh scripts/*.sh; do \
		if [ -f "$$s" ]; then \
			bash -n "$$s" && echo "  ✅ $$s"; \
		fi \
	done
	@echo "✨ Todas as validações passaram com sucesso!"

clean: ## Remove arquivos de backup (*.bak) e temporários
	@echo "Limpando arquivos temporários..."
	@find . -name "*.bak" -type f -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "Limpeza concluída."
