#!/bin/env -S bash
# Adhoc script for creating network debug reports for troubleshooting.

# Verify who is running this script.
#[[ ${EUID} -ne 0 ]] && {
#     echo "$(basename ${0}): This script must be run as root!"
#     exit 1
#} || {

    # List of functions.
    bashFunc=(
        "x2j"
    )

    # Load bash functions.
    for func in ${bashFunc[@]}; do
        [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
            echo "$(basename "${0}"): ${func} not found!"
            exit 1
        } || {
            . "$(dirname "${0}")/bashFunc/${func}.sh"
        }
    done || exit 1

    # Verify script requirements.
    for req in /sbin/conntrack jq sudo x2j; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"): I require \"${req}\" but it's not installed. Aborting."
            exit 1
        }
    done
#}

# Script Functions..
function geoip ()
{
    [[ -f "/opt/GeoLite2-Country.mmdb" ]] && {
        mmdblookup --file "/opt/GeoLite2-Country.mmdb" --ip "${1}" country iso_code 2> /dev/null | awk '/utf8/{gsub(/"/, ""); print $1}'
    } || {
        echo "??"
    }
}

function nattable ()
{
    # Return a formatted nat translation table
    sudo conntrack -L -n --output xml 2> /dev/null | x2j | jq -r '.conntrack.flow[].meta | "\(.[2].id) \(.[0].layer4."@protoname") \(.[0].layer3.src) \(.[0].layer3.dst +":"+ .[0].layer4.dport) \(.[2].use)"'
}

### BEGIN ###

# IP passthrough to vtysh
if [[ "${1}" == "ip" ]]; then
    echo "$(basename "${0}"): show ${@}"
    sudo vtysh -c "show ${1} ${2} ${3} ${4} ${5}"

# IPsec
elif [[ "${1}" == "ipsec" ]]; then
    echo "$(basename "${0}"): ${@}"

    if [[ "${2}" == "det"* ]]; then
        sudo ipsec statusall
    elif [[ "${2}" == "vti" ]]; then
        sudo ip -s xfrm state
    elif [[ "${2}" == "ike" ]]; then
        sudo swanctl --list-sas
    elif [[ "${2}" == "log" ]]; then
        sudo swanctl --log
    else
        sudo ipsec "${2:-status}"
    fi

# Interface statistics
elif [[ "${1}" == "in"* ]]; then
    echo "$(basename "${0}"): show ${@}"
    sudo vtysh -c "show ${1} ${2} ${3}"

# LISTENING ports
elif [[ "${1}" == "listen" ]]; then
    sudo lsof -nP -iTCP -sTCP:LISTEN

# NAT Table
elif [[ "${1}" == "nat" ]]; then

    if [[ "${2}" == "dst" ]]; then
        nattable | awk '/^[0-9]/{print $4}' | sort | uniq -c | sort -nr | while read line; do
            echo "${line} $(geoip "$(awk '{print $NF}' <<< ${line%%:*})") $(awk '/[\t| ]'''${line##*:}'''\//{print $1; exit}' /etc/services)"
        done | awk 'BEGIN{printf("%6s %-23s %-8s %-15s\n", "Hits", "Destination", "Country", "Service")}//{printf("%6s %-23s %-8s %-15s\n", $1, $2, $3, $4)}'
    elif [[ "${2}" == "src" ]]; then
        nattable | awk '/^[0-9]/{print $3}' | sort | uniq -c | sort -nr |\
            awk 'BEGIN{printf("%6s %-18s\n", "Hits", "Source")}//{printf("%6s %-18s\n", $1, $2)}'
    else
        nattable | awk 'BEGIN{printf("%-12s %-6s %-18s %-23s %s\n", "ID", "Proto", "Source", "Destination", "Use" )}//{printf("%-12s %-6s %-18s %-23s %s\n", $1, $2, $3, $4, $5)}'
    fi

# LLDP: show neighbors
elif [[ "${1}" == "lldp" ]]; then
    echo "$(basename "${0}"): lldpcli show neighbors summary"
    sudo lldpcli show neighbors summary

# VLAN
elif [[ "${1}" == "vlan" ]]; then
    sudo awk -F'|' 'BEGIN{printf "%-16s %-7s %s\n", "Name", "ID", "Interface"}/\|.*\|/{printf "%-15s %-7s %s\n", $1, $2, $3}' /proc/net/vlan/config

# Print Help
else cat << EOF
Linux script for creating a network report for visibility and debuging.
Usage: $(basename "${0}") [command]

Command:
  ip             vtysh "show ip ..." cmd pass
  ipsec          Show ipsec ... [detail|ike|log|vti]
  in*            vtysh "show interface ... " cmd pass
  listen         show listening ports
  lldp           show lldp neighbors
  nat            Show current nat table ... [dst|src]
  vlan           Show configured vlans

EOF
fi | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

### FINISH ###
