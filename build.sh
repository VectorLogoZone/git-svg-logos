#!/usr/bin/env bash
#
# build the logo data
#

set -o errexit
set -o pipefail
set -o nounset

echo "INFO: starting at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

#
# load an .env file if it exists
#
ENV_FILE=".env"
if [ -f "${ENV_FILE}" ]; then
    echo "INFO: loading '${ENV_FILE}'"
    export $(cat "${ENV_FILE}")
fi

OUTPUT_DIR=${LOCAL_DIR:-./remote}

#
# load all the git repos
#
echo "INFO: loading logos into ${OUTPUT_DIR}"
./bin/loadrepo.py \
    --output=${OUTPUT_DIR}

# to force it to copy even if no new commits, add:
#    --always \

#
# make the index
#
tar cvzf ${OUTPUT_DIR}/sourceData.tgz ${OUTPUT_DIR}/*/sourceData.json

echo "INFO: complete at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
