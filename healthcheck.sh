#!/bin/ksh

SERVER=$1
TMPDIR=/tmp/$(date +%s)${RANDOM}

if [ ! -e $(pwd)/main_healthcheck.sh ];
then
    echo "Change directory into '$(dirname $0)'"
    echo "to execute this script."
    exit 0
fi

tar cf - . | ssh ${SERVER} "(mkdir ${TMPDIR} && cd ${TMPDIR} && \
    tar xmf - 2>/dev/null && ksh ./main_healthcheck.sh)"
RETVAL=$?

ssh ${SERVER} "rm -rf ${TMPDIR}"

exit ${RETVAL}
