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
    echo "INFO: loading '${ENV_FILE}'"
    export $(cat "${ENV_FILE}")
fi

OUTPUT_DIR=${OUTPUT_DIR:-./local}

#
# LATER: make dir if it doesn't exist
#

#
# load a few so there is some data
#
echo "INFO: loading logos into ${OUTPUT_DIR}"
./bin/loadrepo.py \
    --output=${OUTPUT_DIR} \
    adamfairhead brandicons bestofjs vlz-ar21 svgporn

# to force it to refresh local dir add:
#	--always \

#
# make the index
#
echo "INFO: building index"
tar cvzf ${OUTPUT_DIR}/sourceData.tgz ${OUTPUT_DIR}/*/sourceData.json

#
# copying static files
#
cp -pr www/* "${OUTPUT_DIR}/"

#
# serve it
#
BIND=${BIND:-127.0.0.1}
PORT=${PORT:-4001}
echo "INFO: serving on ${BIND}:${PORT}"
python3 -m http.server ${PORT} \
    --bind "${BIND}" \
    --directory "${OUTPUT_DIR}"
