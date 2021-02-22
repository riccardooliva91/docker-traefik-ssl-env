#!/bin/bash

ABSPATH="${0%/*}/.."
CURRENT_OS=$(uname -s)
FOLDERS=`find -maxdepth 1 -type d ! -path . ! -path ./dumps ! -path ./.idea ! -path ./.git ! -path ./bin`
NETWORK_NAME="traefik_web"

function replace_in_file() {
	if [[ "$CURRENT_OS" = 'Darwin' ]]; then
		sed -i '' -e "$1" "$2"
	else
		sed -i "$1" "$2"
	fi
}

function docker_compose_up() {
	local USER_ID=$(id -u)
	local GROUP_ID=$(id -g)

	replace_in_file "s#USER_ID=.*#USER_ID=${USER_ID}#" "${ABSPATH}/.env"
	replace_in_file "s#GROUP_ID=.*#GROUP_ID=${GROUP_ID}#" "${ABSPATH}/.env"

	if [[ -z "$(docker network ls -q -f name=$NETWORK_NAME)" ]]; then
		docker network create $NETWORK_NAME
	fi

	for FOLDER in $FOLDERS
	do
		docker-compose -f $FOLDER/docker-compose.yml up -d --remove-orphans --build
	done
}

function docker_compose_down() {
	for FOLDER in $FOLDERS
	do
		docker-compose -f $FOLDER/docker-compose.yml down
	done

	if [[ -n "$(docker network ls -q -f name=$NETWORK_NAME)" ]]; then
		docker network rm $NETWORK_NAME
	fi
}

function docker_compose_stop() {
	for FOLDER in $FOLDERS
	do
		docker-compose -f $FOLDER/docker-compose.yml stop
	done
}

function docker_compose_restart() {
	for FOLDER in $FOLDERS
	do
		docker-compose -f $FOLDER/docker-compose.yml restart
	done
}
