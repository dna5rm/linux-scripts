#!/bin/bash
## Create Pre/Post check to assist with network related maintainence.
## 2017 (v1.0) - Script Created by deaves

SITE="$(echo $1 | tr '[:upper:]' '[:lower:]')"
SUCESS="received, 0% packet loss"

PREFILE="/tmp/$SITE.pre"

# Setting the ANSI colors to be used as variables...
esc="$(echo -e '\E')"
CYAN="${esc}[36m"
GREEN="${esc}[32m"
RED="${esc}[31m"
B="${esc}[1m"
B0="${esc}[22m"
CLS="${esc}[0m"

# Create counting variables for status.
ICOUNT="0"
AGE=$([ -f "$PREFILE" ] && { echo \($(date +%s) - $(date +%s --date="$(stat "$PREFILE" --printf='%y\n')")\) / \(60 \* 60 \* 24\) | bc; })

# Make sure we have a site id before continuing.
if [ -z "$SITE" ]; then
    printf "Please specify Site ID...\n\nExample: $B$0$B0 $CYAN""cha1lab$CLS\n"
    exit 0
else
    umask 111
fi

# Fetch list of devices.
function DEVLIST ()
{
    ### HOSTNAME IPADDR ###
    host -l routers.citco.com | awk '/'''$SITE'''/{print $1,$NF}'
}

# Determine the state of each host entry.
function CVAT ()
{
    ping -q -n -c1 $HOST | awk -v host=$HOST '/packet loss/ {printf "%-45s %s\n", host, $0}' |\
        while read LINE; do
            if [[ "$LINE" == *"$SUCESS"* ]] && [ -z "$POST" ]; then
                echo $LINE | tee -a "$PREFILE"
            elif [[ "$LINE" == *"$SUCESS"* ]]; then
                echo $LINE
            else
                exit 1
            fi
        done
}

### List devices & Start main loop ###
DEVLIST | while read HOST IP; do

    # Show Pre/Post status to user.
    if [ "$ICOUNT" -eq "0" -a -f "$PREFILE" ]; then
        POST="YES"
        printf "#%.0s" {1..60}
        printf "\r### Loading prefile: $CYAN$PREFILE$CLS ($AGE days old) ###\n"
    elif [ "$ICOUNT" -eq "0" -a ! -f "$PREFILE" ]; then
        printf "#%.0s" {1..60}
        printf "\r### Creating prefile: $CYAN$PREFILE$CLS ###\n"
    fi

    # Increment line count.
    let ICOUNT++

    # Parse PREFILE.
    if [ "$POST" == "YES" ]; then

        # Check PREFILE for previous sucess.
        if [ -n "$(grep ^"$HOST" "$PREFILE" )" ]; then
            if [[ "$(CVAT)" == *"$SUCESS"* ]]; then
                echo "$HOST ... $GREEN""Up$CLS"
            else
                echo "$HOST ... $RED""Down$CLS"
            fi
        fi

    # Create PREFILE.
    else
        echo -en "$HOST ... Host Down\r$(CVAT)\n"
    fi

done
