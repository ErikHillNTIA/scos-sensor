#!/bin/sh

# autoheal is modified from https://github.com/willfarrell/docker-autoheal

set -e

DOCKER_SOCK=${DOCKER_SOCK:-/var/run/docker.sock}
TMP_DIR=/tmp/restart

if [ -e ${DOCKER_SOCK} ]; then

    rm -rf "$TMP_DIR"
    mkdir "$TMP_DIR"

    # https://docs.docker.com/engine/api/v1.25/

    # Set container selector
    if [ "$AUTOHEAL_CONTAINER_LABEL" == "all" ]; then
        selector() {
            jq -r '.[].Id'
        }
    else
        selector() {
            jq -r '.[] | select(.Labels["'${AUTOHEAL_CONTAINER_LABEL:=autoheal}'"] == "true") | .Id'
        }
    fi

    interruptable_sleep() {
        pid=
        trap '[[ $pid ]] && kill $pid; exit 0' TERM  # Kill sleep and exit if caught SIGTERM from Docker
        sleep ${AUTOHEAL_INTERVAL:=5} & pid=$!
        wait
        pid=
    }

    echo "Monitoring containers for unhealthy status"
    while true; do
        interruptable_sleep

        CONTAINERS=$(curl --no-buffer -s -XGET --unix-socket ${DOCKER_SOCK} http://localhost/containers/json | selector)
        for CONTAINER in $CONTAINERS; do
            HEALTH=$(curl --no-buffer -s -XGET --unix-socket ${DOCKER_SOCK} http://localhost/containers/${CONTAINER}/json | jq -r .State.Health.Status)
            if [ "unhealthy" = "$HEALTH" ]; then
                DATE=$(date +%d-%m-%Y" "%H:%M:%S)
                echo "$DATE Container ${CONTAINER:0:12} found to be unhealthy"
                touch "$TMP_DIR/$CONTAINER"
            fi
        done

        for CONTAINER in `ls $TMP_DIR`; do
            DATE=$(date +%d-%m-%Y" "%H:%M:%S)
            echo "$DATE Restarting container ${CONTAINER:0:12}"
            curl -f --no-buffer -s -XPOST --unix-socket ${DOCKER_SOCK} http://localhost/containers/${CONTAINER}/restart && rm "$TMP_DIR/$CONTAINER" || echo "$DATE Restarting container ${CONTAINER:0:12} failed"
        done
    done

else
    echo "Docker socket doesn't exist"
    exit 1
fi
