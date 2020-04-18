#!/usr/bin/env bash
#
# deploy to remote server
#

set -o errexit
set -o pipefail
set -o nounset

echo "INFO: starting at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

if ! [ -x "$(command -v jq)" ]; then
	echo "ERROR: jq is not installed."
	exit 1
fi

if ! [ -x "$(command -v rclone)" ]; then
	echo "ERROR: rclone is not installed."
	exit 2
fi

#
# load an .env file if it exists
#
ENV_FILE=".env"
if [ -f "${ENV_FILE}" ]; then
    echo "INFO: loading '${ENV_FILE}'"
    export $(cat "${ENV_FILE}")
fi

if [ ! -d "${LOCAL_DIR}" ]; then
    echo "ERROR: build directory '${LOCAL_DIR}' does not exist.  Run 'build.sh' first!"
    exit 3
fi

#
# LATER: test that ${REMOTE_LOCATION} is valid rcloneconfig:bucket
#

#
# copy local back to remote storage
#
echo "INFO: copy to ${REMOTE_LOCATION}"
rclone copy "${LOCAL_DIR}" "${REMOTE_LOCATION}" \
    --progress 

#
# copying static files
#
echo "INFO: copying static files"
rclone copy ./www ${REMOTE_LOCATION} \
    --no-update-modtime

# for debugging:
#    --progress \
#    -vvv

echo "INFO: creating status.json"
echo '{}' | \
    jq '.success|=true' | \
    jq '.message|="OK"' | \
    jq ".commit|=\"$(git rev-parse HEAD | cut -c -7)\"" | \
    jq ".lastmod|=\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" | \
    jq ".tech|=\"$(rclone --version | head -n 1 | tr -d '\n')\"" | \
    jq .  --compact-output | \
    rclone rcat ${REMOTE_LOCATION}/status.json

echo "INFO: complete at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
