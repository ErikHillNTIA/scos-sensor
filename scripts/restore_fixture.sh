#!/bin/bash

# Exit on error
set -e

REPO_ROOT=${REPO_ROOT:=$(git rev-parse --show-toplevel)}
PROGRAM_NAME=${0##*/}
INPUT="$1"


echo_usage() {
    cat << EOF
Restore a fixture file.

Usage: $PROGRAM_NAME filename

Example:
    $PROGRAM_NAME ./src/capabilities/fixtures/greyhound-2018-02-22.json

EOF

    exit 0
}


if [[ ! "$INPUT" || "$INPUT" == "-h" || "$INPUT" == "--help" ]]; then
    echo_usage
    exit 0
fi

HOST_PATH=$(readlink -e "$INPUT")
FILENAME=$(basename "$INPUT")
CONTAINER_PATH="/tmp/$FILENAME"

if [[ ! -e "$HOST_PATH" ]]; then
    echo "Fixture file \"$HOST_PATH\" doesn't exist."
    exit 1
fi

set +e  # this command may "fail"
DB_RUNNING=$(docker-compose -f ${REPO_ROOT}/docker-compose.yml ps db |grep Up)
API_RUNNING=$(docker-compose -f ${REPO_ROOT}/docker-compose.yml ps api |grep Up)
set -e

# Ensure database container is running
docker-compose -f ${REPO_ROOT}/docker-compose.yml up -d db

# Load given fixture file into database
if [[ "$API_RUNNING" ]]; then
    API_CONTAINER=$(docker-compose -f ${REPO_ROOT}/docker-compose.yml ps -q api)
    docker cp "$HOST_PATH" ${API_CONTAINER}:/tmp
    docker-compose -f ${REPO_ROOT}/docker-compose.yml exec api \
                   /src/manage.py loaddata "$CONTAINER_PATH"
else
    docker-compose  -f ${REPO_ROOT}/docker-compose.yml run \
                    -v "$HOST_PATH":"$CONTAINER_PATH" \
                    --rm api /src/manage.py loaddata "$CONTAINER_PATH"
fi

# If the DB was already running, leave it up
if [[ ! "$DB_RUNNING" ]]; then
    # Stop database container
    docker-compose -f ${REPO_ROOT}/docker-compose.yml stop db
fi

echo "Restored fixture from $INPUT."
