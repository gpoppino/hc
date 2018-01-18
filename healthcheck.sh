#!/bin/bash

SERVER=$1
TMPDIR=/tmp/$(date +%s)${RANDOM}

if [ ! -e $(pwd)/main_healthcheck.sh ];
then
    echo "Change directory into '$(dirname $0)'"
    echo "to execute this script."
    exit 0
fi

tar cf - . | ssh -oStrictHostKeyChecking=no -oCheckHostIP=no \
    -oConnectTimeout=20 ${SERVER} "(mkdir ${TMPDIR} && cd ${TMPDIR} && \
    tar xmf - 2>/dev/null && bash ./main_healthcheck.sh)"
RETVAL=$?

ssh ${SERVER} "rm -rf ${TMPDIR}"

exit ${RETVAL}
