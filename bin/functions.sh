#!/bin/bash

ABSPATH="${0%/*}/.."
CURRENT_OS=$(uname -s)
FOLDERS=`find -maxdepth 1 -type d ! -path . ! -path ./dumps ! -path ./.idea ! -path ./.git ! -path ./bin`
source "${ABSPATH}/.env"

function replace_in_file() {
	if [[ "$CURRENT_OS" = 'Darwin' ]]; then
		sed -i '' -e "$1" "$2"
	else
		sed -i "$1" "$2"
	fi
}

function docker_compose_up() {
  # Env replaces
	replace_in_file "s#USER_ID=.*#USER_ID=${USER_ID}#" "${ABSPATH}/.env"
	replace_in_file "s#GROUP_ID=.*#GROUP_ID=${GROUP_ID}#" "${ABSPATH}/.env"
	if [[ -e "${ABSPATH}/traefik/traefik.yml" ]]; then
	  rm "${ABSPATH}/traefik/traefik.yml"
  fi

  # Traefik template preparation
  cp "${ABSPATH}/traefik/traefik.yml.template" "${ABSPATH}/traefik/traefik.yml"
	replace_in_file "s#dashboard: .*#dashboard: ${TRAEFIK_DASHBOARD}#" "${ABSPATH}/traefik/traefik.yml"
	replace_in_file "s#insecure: .*#insecure: ${TRAEFIK_DASHBOARD_INSECURE}#" "${ABSPATH}/traefik/traefik.yml"

  # Create network if needed
	if [[ -z "$(docker network ls -q -f name=$NETWORK_NAME)" ]]; then
		docker network create $NETWORK_NAME
	fi

  # Bring up projects
	for FOLDER in $FOLDERS
	do
	  if [[ -e "$FOLDER/docker-compose.yml" ]]; then
	    rm "$FOLDER/docker-compose.yml"
    fi
    cp "$FOLDER/docker-compose.yml.template" "$FOLDER/docker-compose.yml"
    replace_in_file "s#name: WEBNETWORKNAME#name: ${NETWORK_NAME}#" "$FOLDER/docker-compose.yml"

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
