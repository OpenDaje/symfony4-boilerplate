# Makefile
#
# This file contains the commands most used in DEV, plus the ones used in CI and PRD environments.


# Mute all `make` specific output. Comment this out to get some debug information.
.SILENT:

# .DEFAULT: If the command does not exist in this makefile
# default:  If no command was specified
.DEFAULT default:
	if [ -f ./Makefile.custom ]; then \
	    $(MAKE) -f Makefile.custom "$@"; \
	else \
	    if [ "$@" != "" ]; then echo "Command '$@' not found."; fi; \
	    $(MAKE) help; \
	    if [ "$@" != "" ]; then exit 2; fi; \
	fi

help:
	@echo "Usage:"
	@echo "     make [command]"
	@echo
	@echo "Available commands:"
	@grep '^[^#[:space:]].*:' Makefile | grep -v '^default' | grep -v '^\.' | grep -v '=' | grep -v '^_' | sed 's/://' | xargs -n 1 echo ' -'

########################################################################################################################


CONTAINER_API="symfony4boilerplate_php_1"


#   We run this in tst ENV so that we never run it with xdebug on
code-analyse:
	echo "    - Execution: phpstan"
	php vendor/bin/phpstan analyse


cs-fix:
	echo "    "
	echo "    - Execution: php-cs-fixer"
	echo "    - Fixing code style in src/"
	php vendor/bin/php-cs-fixer fix src --verbose
	#echo "    "
	#echo "    - Execution: php-cs-fixer"
	#echo "    - Fixing code style in test/"
	#php vendor/bin/php-cs-fixer fix tests --verbose
	#php vendor/bin/php-cs-fixer fix core --verbose
	#php vendor/bin/php-cs-fixer fix lib --verbose


cs-fix-check:
	echo "    - Execution: php-cs-fixer"
	echo "    - Checking code style in src/"
	php vendor/bin/php-cs-fixer fix src --dry-run --verbose
	#echo "    "
	#echo "    - Execution: php-cs-fixer"
	#echo "    - Checking code style in test/"
	#php vendor/bin/php-cs-fixer fix tests --dry-run --verbose
	#php vendor/bin/php-cs-fixer fix core --dry-run --verbose
	#php vendor/bin/php-cs-fixer fix lib --dry-run --verbose




shell:
	docker exec -it ${CONTAINER_API} bash

up:
	#if [ ! -f ${DB_PATH} ]; then $(MAKE) db-setup; fi
	$(eval UP=ENV=dev docker-compose  up -t 0)
	$(eval DOWN=ENV=dev docker-compose  down -t 0)
	- bash -c "trap '${DOWN}' EXIT; ${UP}"

down:
	- docker-compose  down --volumes --remove-orphans