#!/bin/bash
#
# run locally for dev
#

set -o errexit
set -o pipefail
set -o nounset

#
# load an .env file if it exists
#
ENV_FILE="./.env"
if [ -f "${ENV_FILE}" ]; then
    echo "INFO: loading '${ENV_FILE}'!"
    export $(cat "${ENV_FILE}")
fi

OUTPUT_DIR=${OUTPUT_DIR:-./logos}

#
# load a few so there is some data
#
./bin/loadrepo.py \
    --output=${OUTPUT_DIR} \
    adamfairhead brandicons bestofjs vlz-ar21 svgporn

tar cvzf ${OUTPUT_DIR}/sourceData.tgz ${OUTPUT_DIR}/*/sourceData.json