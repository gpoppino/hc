#!/bin/ksh

SERVER=$1
TMPDIR=/tmp/$(date +%s)${RANDOM}

tar cf - . | ssh ${SERVER} "(mkdir ${TMPDIR} && cd ${TMPDIR} && \
    tar xmf - 2>/dev/null && ksh ./mini_healthcheck.sh && \
    cd .. && rm -rf ${TMPDIR})"
