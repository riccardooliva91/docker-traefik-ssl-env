#!/bin/bash

source "${0%/*}/functions.sh"

ENV_FILE_PATH="${0%/*}/../.env"

if [[ ! -e "$ENV_FILE_PATH" ]]; then
	cp .env.example .env
fi

prepare_env
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
	-ci | --restart-hard )
		docker_compose_down
		docker_compose_up
		;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi
