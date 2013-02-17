#!/bin/ksh

GENERAL_CONFIG="config.general"
EXTENSIONS_DIR="./extensions"

extensions_checklist=""
extensions_infolist=""

get_checklist()
{
    h=$(hostname | awk 'BEGIN { FS="." } { print $1 }' | tr 'A-Z' 'a-z')
    groups=$(cat ${GENERAL_CONFIG} | awk 'BEGIN { FS="=" } \
            $1 ~ /group_.*_servers/ { print $1 }')
    for g in ${groups};
    do
        eval echo '$'${g} | \
            awk -v s="$h" '$0 ~ s && s != "" { exit 1 }'

        if [[ $? -gt 0 ]] ;
        then
            name=$(echo ${g} | \
                awk '{ split($0, a, "_"); print a[2] }')
            cl=$(eval echo '$'group_${name}_checks)
            break
        fi
    done

    checklist=${cl:-$checklist}
    checklist="${checklist} ${extensions_checklist}"
    echo ${checklist}
}

detect_platform()
{
    PLATFORM=$(uname | tr '[A-Z]' '[a-z]')

    if [[ ! -e "healthcheck_${PLATFORM}" ]] ; 
    then
        echo "Platform ${PLATFORM} is not supported. Bye!"
        exit 1
    fi
}

run_probes()
{
    for ext in $(ls $EXTENSIONS_DIR);
    do
        check=""
        info=""
        . $EXTENSIONS_DIR/${ext}
        probe=$(cat $EXTENSIONS_DIR/${ext} | 
            awk '$1 ~ /probe_.*()/ { print $1 }' | sed 's/()//g')

        [ -z ${probe} ] && continue

        echo "${probe}" | awk '{ printf "Running probes ... %-26s\r", $1 }'
        ${probe}
        RETVAL=$?

        [ $RETVAL -eq 0 ] && check=$(cat $EXTENSIONS_DIR/${ext} | \
            awk '$1 ~ /^check_.*()/ { print $1 }' | sed 's/()//g')
        [ $RETVAL -eq 0 ] && info=$(cat $EXTENSIONS_DIR/${ext} | \
            awk '$1 ~ /^show_.*()/ { print $1 }' | sed 's/()//g')
        extensions_checklist="${extensions_checklist} ${check}" 
        extensions_infolist="${extensions_infolist} ${info}" 
    done
    echo "done" | awk '{ printf "Running probes ... %-26s\n", $1 }'
}

run_checks()
{
    echo "= Health check for $(hostname -s) [Begin] -- $(date) ="
    echo
    infolist="${infolist} ${extensions_infolist}"
    for show_info in ${infolist};
    do
        echo "${show_info}" | awk '{ printf "%-26s:  ", $1 }'
        ${show_info}
    done

    GLOBAL_RETVAL=0
    checklist=$( get_checklist )
    for run_test in ${checklist};
    do
        ${run_test}
        RETVAL=$?

        echo "${run_test}" | awk '{ printf "%-26s:  ", $1 }'
        [ $RETVAL -eq 0 ] && echo "[  OK  ]" || echo "[FAILED]"

        [ $RETVAL -gt 0 ] && \
            GLOBAL_RETVAL=$((${GLOBAL_RETVAL} + ${RETVAL}))
    done
    echo
    echo "= Health check for $(hostname -s) [Done] -- $(date) ="

    return ${GLOBAL_RETVAL}
}

PLATFORM=""
detect_platform

. ./healthcheck_${PLATFORM}
. ./${GENERAL_CONFIG}

[ ${RUN_PROBES} -eq 0 ] && run_probes
run_checks
RETVAL=$?

exit ${RETVAL}

