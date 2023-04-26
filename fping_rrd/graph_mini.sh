#!/bin/env -S bash
## Create a  mini graph from a RRD file

fping_rrd="${1}"
COLOR=( "FF5500" )

# Verify script requirements.
for req in fping; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require \"${req}\" but it's not installed. Aborting."
        exit 1
    }
done

function rrd_graph_cmd ()
{
cat << EOF
rrdtool graph "$(dirname "${fping_rrd}")/$(basename "${fping_rrd%.*}")_mini.png"
--start "${START}" --end "${END}"
--title "$(date -d "${START}") ($(awk -v TIME=$TIME 'BEGIN {printf "%.1f hr", TIME/3600}'))"
--height 65 --width 600
--vertical-label "Seconds"
--color BACK#F3F3F3
--color CANVAS#FDFDFD
--color SHADEA#CBCBCB
--color SHADEB#999999
--color FONT#000000
--color AXIS#2C4D43
--color ARROW#2C4D43
--color FRAME#2C4D43
--border 1
--font TITLE:10:"Arial"
--font AXIS:8:"Arial"
--font LEGEND:8:"Courier"
--font UNIT:8:"Arial"
--font WATERMARK:6:"Arial"
--imgformat PNG
EOF
}

function rrd_graph_opts ()
{
rrd_idx=0
cat << EOF
DEF:median$((rrd_idx))="${fping_rrd}":median:AVERAGE
DEF:loss$((rrd_idx))="${fping_rrd}":loss:AVERAGE
$(for ((i=1;i<=PINGS;i++)); do echo "DEF:ping$((rrd_idx))p$((i))=\"${fping_rrd}\":ping$((i)):AVERAGE"; done)
CDEF:ploss$((rrd_idx))=loss$((rrd_idx)),20,/,100,*
CDEF:dm$((rrd_idx))=median$((rrd_idx)),0,100000,LIMIT
$(for ((i=1;i<=PINGS;i++)); do echo "CDEF:p$((rrd_idx))p$((i))=ping$((rrd_idx))p$((i)),UN,0,ping$((rrd_idx))p$((i)),IF"; done)
$(echo -n "CDEF:pings$((rrd_idx))=$((PINGS)),p$((rrd_idx))p1,UN"; for ((i=2;i<=PINGS;i++)); do echo -n ",p$((rrd_idx))p$((i)),UN,+"; done; echo ",-")
$(echo -n "CDEF:m$((rrd_idx))=p$((rrd_idx))p1"; for ((i=2;i<=PINGS;i++)); do echo -n ",p$((rrd_idx))p$((i)),+"; done; echo ",pings$((rrd_idx)),/")
$(echo -n "CDEF:sdev$((rrd_idx))=p$((rrd_idx))p1,m$((rrd_idx)),-,DUP,*"; for ((i=2;i<=PINGS;i++)); do echo -n ",p$((rrd_idx))p$((i)),m$((rrd_idx)),-,DUP,*,+"; done; echo ",pings$((rrd_idx)),/,SQRT")
CDEF:dmlow$((rrd_idx))=dm$((rrd_idx)),sdev$((rrd_idx)),2,/,-
CDEF:s2d$((rrd_idx))=sdev$((rrd_idx))
AREA:dmlow$((rrd_idx))
AREA:s2d$((rrd_idx))#${COLOR}30:STACK
LINE1:dm$((rrd_idx))#${COLOR}:"$(basename "${fping_rrd%.*}" | awk -F'-' '{print $NF}')\t"
VDEF:avmed$((rrd_idx))=median$((rrd_idx)),AVERAGE
VDEF:avsd$((rrd_idx))=sdev$((rrd_idx)),AVERAGE
CDEF:msr$((rrd_idx))=median$((rrd_idx)),POP,avmed$((rrd_idx)),avsd$((rrd_idx)),/
VDEF:avmsr$((rrd_idx))=msr$((rrd_idx)),AVERAGE
GPRINT:avmed$((rrd_idx)):"Median RTT\: %5.2lfms"
GPRINT:ploss$((rrd_idx)):AVERAGE:"Loss\: %5.1lf%%"
GPRINT:avsd$((rrd_idx)):"Std Dev\: %5.2lfms"
GPRINT:avmsr$((rrd_idx)):"Ratio\: %5.1lfms\\j"
COMMENT:"Probe\: $((PINGS)) pings every $((STEP)) seconds"
COMMENT:"$(basename "${fping_rrd}")\\j"
EOF
}

if [ ! -r "${fping_rrd}" ]; then
    printf "${0} \"file.rrd\"\n"
else
    STEP=$(rrdtool info "${fping_rrd}" | awk '/^step/{print $NF}')
    PINGS=$(rrdtool info "${fping_rrd}" | awk '/^ds.ping.*index/{count++} END{print count}')

    START="$([ -z "${2}" ] && echo "-9 hours" || echo "${2}")"
    END="$([ -z "${3}" ] && echo "now" || echo "${3}")"
    TIME=$(( $(date -d "${END}" +%s) - $(date -d "${START}" +%s) ))

    eval $(rrd_graph_cmd; rrd_graph_opts)
fi
