#!/bin/env -S bash
## FPing data collector for RRDTOOL
#
# Crontab:
#   */5 * * * *     ${HOME}/fping_rrd.sh 192.0.2.1 192.0.2.2
#

STEP=300 # 5min
PINGS=20 # 20 pings

# The first ping is usually an outlier so I add an extra ping.
fping_hosts="${@}"
fping_opts="-C $((PINGS+1)) -q -B1 -r1 -i10"
rrd_path="${HOME}/public_html"
rrd_timestamp=$(date +%s)

# Verify script requirements.
for req in fping rrdtool; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require \"${req}\" but it's not installed. Aborting."
        exit 1
    }
done

function calc_median ()
{
    sort -n | awk '{ count[NR] = $1; }
        END {
            if (NR % 2) { print count[(NR + 1) / 2] }
            else { print (count[(NR / 2)] + count[(NR / 2) + 1]) / 2.0 }
        }'
}

function rrd_create ()
{
    rrdtool create "${fping_rrd}" \
        --start now-2h --step $((STEP)) \
        DS:loss:GAUGE:$((STEP*2)):0:$((PINGS)) \
        DS:median:GAUGE:$((STEP*2)):0:180 \
        $(seq -f " DS:ping%g:GAUGE:$((STEP*2)):0:180" 1 $((PINGS++))) \
        RRA:AVERAGE:0.5:1:1008 \
        RRA:AVERAGE:0.5:12:4320 \
        RRA:MIN:0.5:12:4320 \
        RRA:MAX:0.5:12:4320 \
        RRA:AVERAGE:0.5:144:720 \
        RRA:MAX:0.5:144:720 \
        RRA:MIN:0.5:144:720
}

function rrd_update ()
{
    rrd_loss=0
    rrd_median=""
    rrd_rev=$((PINGS))
    rrd_name=""
    rrd_value="${rrd_timestamp}"

    for rrd_idx in $(seq 1 $((rrd_rev))); do
        rrd_name="${rrd_name}$([[ ${rrd_idx} -gt "1" ]] && echo ":")ping$((rrd_idx))"
        rrd_value="${rrd_value}:${fping_array[-$((rrd_rev))]}"
        rrd_median="${fping_array[-$((rrd_rev))]}\n${rrd_median}"

        [ "${fping_array[-$((rrd_rev))]}" == "-" ] && (( rrd_loss++ ))

        (( rrd_rev-- ))
    done

    rrd_median="$(printf "${rrd_median}" 2> /dev/null | calc_median)"

    if [[ ${?} -eq 0 ]]; then
        rrdtool update "${fping_rrd}" --template $(echo ${rrd_name}:median:loss ${rrd_value}:${rrd_median}:${rrd_loss} | sed 's/-/U/g')
    else
        echo "[ERROR] $(basename "${0}"):${FUNCNAME[0]} - Host may not be reachable!"
    fi

    unset rrd_loss rrd_median rrd_rev rrd_name rrd_value
}

fping ${fping_opts} ${fping_hosts} 2>&1 | while read fping_line; do
    fping_array=( ${fping_line} )
    fping_rrd="${rrd_path}/fping_$(hostname -s)-${fping_array[0],,}.rrd"

    # Create RRD file.
    if [ ! -f "${fping_rrd}" ]; then
        rrd_create
    fi

    # Update RRD file.
    if [ -f "${fping_rrd}" ]; then
        rrd_last=$(( ${rrd_timestamp} - $(rrdtool last "${fping_rrd}") ))
        [[ $((rrd_last)) -ge $((STEP)) ]] && rrd_update
    fi && unset rrd_last
done
