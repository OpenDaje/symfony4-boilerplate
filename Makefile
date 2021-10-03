SHELL='/bin/bash'
# Makefile
#
# This file contains the commands most used in DEV, plus the ones used in CI and PRD environments.


# Mute all `make` specific output. Comment this out to get some debug information.
.SILENT:

ifndef APP_CONTAINER
APP_CONTAINER=docker-compose exec php
endif


# .DEFAULT: If the command does not exist in this makefile
# default:  If no command was specified
.DEFAULT:
	if [ -f ./Makefile.custom ]; then \
	    $(MAKE) -f Makefile.custom "$@"; \
	else \
	    if [ "$@" != "" ]; then echo "Command '$@' not found."; fi; \
	    $(MAKE) help; \
	    if [ "$@" != "" ]; then exit 2; fi; \
	fi


.PHONY: help
help: ## Show help menu
	@echo "Usage:"
	@echo "     make [command]"
	@echo
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
#	@grep '^[^#[:space:]].*:' Makefile | grep -v '^default' | grep -v '^\.' | grep -v '=' | grep -v '^_' | sed 's/://' | xargs -n 1 echo ' -'



########################################################################################################################


.PHONY: up
up: ## Start docker containers
	- docker-compose  up -d


.PHONY: down
down: ## Stop docker containers
	- docker-compose  down --volumes --remove-orphans


.PHONY: status
status: ## Show docker containers status
	- docker-compose ps


.PHONY: bash
bash: ## Get bash inside application container
	#- @HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) docker-compose exec php bash
	- docker-compose exec php bash


.PHONY: cs
cs: ## Run code style analysis
	$(APP_CONTAINER) php vendor/bin/php-cs-fixer fix src --dry-run --verbose


.PHONY: cs-fix
cs-fix: ## Fix code style issues
	$(APP_CONTAINER) php vendor/bin/php-cs-fixer fix src --verbose


.PHONY: coding-standard
coding-standard: ## Fix code style issues
	$(APP_CONTAINER) mkdir -p var/tools/ecs
	$(APP_CONTAINER) php vendor/bin/ecs check --fix --verbose


.PHONY: coding-standard-check
coding-standard-check: ## Run code style analysis
	$(APP_CONTAINER) mkdir -p var/tools/ecs
	$(APP_CONTAINER) php vendor/bin/ecs check --verbose


.PHONY: stan
stan: ## Static analysis with phpstan
	echo "    - Execution: phpstan"
	$(APP_CONTAINER) php vendor/bin/phpstan analyse
