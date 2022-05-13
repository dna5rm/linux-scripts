#!/bin/env -S bash
## Create a SmokePing like graph from a RRD file

# Enable for debuging
#set -x

fping_rrd="${1}"
COLOR=( "0F0f00" "00FF00" "00BBFF" "0022FF" "8A2BE2" "FA0BE2" "C71585" "FF0000" )
LINE=".5"

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
rrdtool graph "$(basename ${fping_rrd%.*})_smoke.png"
--start "${START}" --end "${END}"
--title "$(basename ${fping_rrd%.*} | awk -F'_' '{print $NF}')"
--height 95 --width 600
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
--font LEGEND:9:"Courier"
--font UNIT:8:"Arial"
--font WATERMARK:7:"Arial"
--imgformat PNG
EOF
}

function rrd_graph_opts ()
{
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
AREA:s2d$((rrd_idx))#${COLOR[0]}30:STACK
\
VDEF:avmed$((rrd_idx))=median$((rrd_idx)),AVERAGE
VDEF:avsd$((rrd_idx))=sdev$((rrd_idx)),AVERAGE
CDEF:msr$((rrd_idx))=median$((rrd_idx)),POP,avmed$((rrd_idx)),avsd$((rrd_idx)),/
VDEF:avmsr$((rrd_idx))=msr$((rrd_idx)),AVERAGE
LINE3:avmed$((rrd_idx))#${COLOR[1]}15:
\
COMMENT:"\t\t"
COMMENT:"Average"
COMMENT:"Maximum"
COMMENT:"Minimum"
COMMENT:"Current"
COMMENT:"Std Dev"
COMMENT:" \\j"
\
COMMENT:"Median RTT\: \t"
GPRINT:avmed$((rrd_idx)):"%.2lf"
GPRINT:median$((rrd_idx)):MAX:"%.2lf"
GPRINT:median$((rrd_idx)):MIN:"%.2lf"
GPRINT:median$((rrd_idx)):LAST:"%.2lf"
GPRINT:avsd$((rrd_idx)):"%.2lf"
COMMENT:" \\j"
\
COMMENT:"Packet Loss\:\t"
GPRINT:ploss$((rrd_idx)):AVERAGE:"%.2lf%%"
GPRINT:ploss$((rrd_idx)):MAX:"%.2lf%%"
GPRINT:ploss$((rrd_idx)):MIN:"%.2lf%%"
GPRINT:ploss$((rrd_idx)):LAST:"%.2lf%%"
COMMENT:"  -  "
COMMENT:" \\j"
\
COMMENT:"Loss Colors\:\t"
CDEF:me0=loss$((rrd_idx)),-1,GT,loss$((rrd_idx)),0,LE,*,1,UNKN,IF,median$((rrd_idx)),*
CDEF:meL0=me0,${LINE},-
CDEF:meH0=me0,0,*,${LINE},2,*,+
AREA:meL0
STACK:meH0#${COLOR[1]}:" 0/$((PINGS))"
CDEF:me1=loss$((rrd_idx)),0,GT,loss$((rrd_idx)),1,LE,*,1,UNKN,IF,median$((rrd_idx)),*
CDEF:meL1=me1,${LINE},-
CDEF:meH1=me1,0,*,${LINE},2,*,+
AREA:meL1
STACK:meH1#${COLOR[2]}:" 1/$((PINGS))"
CDEF:me2=loss$((rrd_idx)),1,GT,loss$((rrd_idx)),2,LE,*,1,UNKN,IF,median$((rrd_idx)),*
CDEF:meL2=me2,${LINE},-
CDEF:meH2=me2,0,*,${LINE},2,*,+
AREA:meL2
STACK:meH2#${COLOR[3]}:" 2/$((PINGS))"
CDEF:me3=loss$((rrd_idx)),2,GT,loss$((rrd_idx)),3,LE,*,1,UNKN,IF,median$((rrd_idx)),*
CDEF:meL3=me3,${LINE},-
CDEF:meH3=me3,0,*,${LINE},2,*,+
AREA:meL3
STACK:meH3#${COLOR[4]}:" 3/$((PINGS))"
CDEF:me4=loss$((rrd_idx)),3,GT,loss$((rrd_idx)),4,LE,*,1,UNKN,IF,median$((rrd_idx)),*
CDEF:meL4=me4,${LINE},-
CDEF:meH4=me4,0,*,${LINE},2,*,+
AREA:meL4
STACK:meH4#${COLOR[5]}:" 4/$((PINGS))"
CDEF:me10=loss$((rrd_idx)),4,GT,loss$((rrd_idx)),10,LE,*,1,UNKN,IF,median$((rrd_idx)),*
CDEF:meL10=me10,${LINE},-
CDEF:meH10=me10,0,*,${LINE},2,*,+
AREA:meL10
STACK:meH10#${COLOR[6]}:"10/$((PINGS))"
CDEF:me19=loss$((rrd_idx)),10,GT,loss$((rrd_idx)),19,LE,*,1,UNKN,IF,median$((rrd_idx)),*
CDEF:meL19=me19,${LINE},-
CDEF:meH19=me19,0,*,${LINE},2,*,+
AREA:meL19
STACK:meH19#${COLOR[7]}:"19/$((PINGS))\\j"
\
COMMENT:"Probe\: $((PINGS)) pings every $((STEP)) seconds"
COMMENT:"$(date -d "${START}" | sed 's/\:/\\\:/g') ($(awk -v TIME=$TIME 'BEGIN {printf "%.1f hr", TIME/3600}'))\\j"
EOF
}

if [ ! -r "${fping_rrd}" ]; then
    printf "${0} \"file.rrd\"\n"
else
    STEP=$(rrdtool info "${fping_rrd}" | awk '/^step/{print $NF}')
    PINGS=$(rrdtool info "${fping_rrd}" | awk '/^ds.ping.*index/{count++} END{print count}')

    START="$([ -z "${2}" ] && echo "-7 hours" || echo "${2}")"
    END="$([ -z "${3}" ] && echo "now" || echo "${3}")"
    TIME=$(( $(date -d "${END}" +%s) - $(date -d "${START}" +%s) ))

    eval $(rrd_graph_cmd; rrd_graph_opts)
fi
