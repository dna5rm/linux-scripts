#!/bin/env -S bash

HOSTS="204.122.8.12 204.122.12.12 104.129.68.6 66.9.65.54 24.38.64.99"
LOGFILE="${HOME}/public_html/mtreport.log.xz"

# FUNCTION: End Script if error.
function DIE ()
{
    echo "ERROR: Validate \"$_\" is installed and working on your system."
    exit 0
}

function MTRRUN ()
{
    mtr --report --report-cycles 1 --raw --no-dns $HOST | awk 'NR%2==1 {printf  " "$NF;} NR%2==0 {printf "|"$NF/1000;}'
}

# Validate script requirements are meet.
type -p /usr/sbin/mtr > /dev/null || DIE

if [ "$1" == "-p" ]; then

    # Main Loop.
    for HOST in $HOSTS; do
        echo "$(date +%s)$(MTRRUN)" | xz -9 -c >> "$LOGFILE"
    done

elif [ ! -z "$1" ]; then

    xzgrep "$1" "$LOGFILE" | while read LINE; do
        ARRAY=( $LINE )

        ## Show the Timestamp ##
        echo; date -d @${ARRAY[0]} +'%Y/%m/%d_%H:%M:%S'
        ARRAY=("${ARRAY[@]:1}") # Drop the timestamp array element

        ## Itirate through hops ##
        for HOP in "${ARRAY[@]}"; do
            [ -z "$COUNT" ] && { COUNT=0; }
            echo "$COUNT|$HOP ms"
            let COUNT++ # Increment Hop Count
        done | column -ts\|
    done

else
    echo "Poll --> $0: -p"
    echo "View --> $0: <IP>"
fi
