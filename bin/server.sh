#!/bin/bash

source "${0%/*}/functions.sh"

ENV_FILE_PATH="${0%/*}/../.env"

if [[ ! -e "$ENV_FILE_PATH" ]]; then
	log_info "File .env not found creating it from .env.example"
	cp .env.example .env
fi

source $ENV_FILE_PATH

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
	-u | --up )
		docker_compose_up
		;;
	-s | --stop )
		docker_compose_stop
		;;
	-r | --restart )
		docker_compose_restart
		;;
	-d | --down )
		docker_compose_down
		;;
	-ci | --composer-install )
		docker_compose_composer_install
		;;
	-ni | --npm-install )
		docker_compose_npm_install
		;;
	-e | --exec )
		shift;
		docker_compose_exec $*
		;;
	-tc | --theme-composer )
		shift;
		docker_compose_theme_composer $*
		;;
	--status )
		docker ps
		;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi
