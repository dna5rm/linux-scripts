#!/bin/env -S bash
# Adhoc script for system debug and troubleshooting.

# Verify who is running this script.
[[ ${EUID} -ne 0 ]] && {
     echo "$(basename ${0}): This script must be run as root!"
     exit 1
}

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
    xq -r '.conntrack.flow[].meta | "\(.[2].id) \(.[0].layer4."@protoname") \(.[0].layer3.src) \(.[0].layer3.dst +":"+ .[0].layer4.dport) \(.[2].use)"' <(conntrack -L -n --output xml 2> /dev/null)
}

### BEGIN ###

# ARP Cache
if [[ "${1}" == "arp" ]]; then
    /sbin/arp -a | awk 'BEGIN{print "Address", "HWtype", "HWaddress", "Iface"}/ether/{gsub(/[)|(|\]|\[]/, ""); print $(NF-5), $(NF-2), $(NF-3), $NF}' | column -t

# DHCP leases
elif [[ "${1}" == "dhcp" ]]; then
    /sbin/dhcp-lease-list

# IP passthrough to vtysh
elif [[ "${1}" == "ip" ]]; then
    echo "$(basename "${0}"): show ${@}"
    vtysh -c "show ${1} ${2} ${3} ${4} ${5}"

# IPv6
elif [[ "${1}" == "ipv6" ]]; then

    # show ipv6 neighbors
    if [[ "${2}" == "nei"* ]]; then
        printf "%-18s %-10s %-40s %-6s %-26s\n" "MAC" "State" "Address" "Dev" "Manufacturer"

        ip -6 neighbor | awk '{if($(NF-1) == "router") { rtr="y"; }; if($4 == "lladdr") { print $1,$3,$5,$NF,rtr; rtr="" }}' |\
        while read addr dev mac nud rtr; do

        [[ -f "/usr/local/etc/oui.txt" ]] && {
            oui="$(echo ${mac:0:8} | sed 's/://g;s/.*/\U&/')"
            vendor="$(awk -F'\t' 'BEGIN{IGNORECASE = 1}/^'''$oui'''/{gsub(/\r/, ""); print $NF}' "/usr/local/etc/oui.txt")"
        }

        [[ "${rtr,,}" == "y" ]] && {
            printf "%-18s %-10s %-40s %-6s %s\n" "${mac}" "${nud}" "${addr}" "${dev}" "${vendor:--}" |\
            sed "1 s,.*,$(tput smul)&$(tput sgr0),"
        } || {
            printf "%-18s %-10s %-40s %-6s %s\n" "${mac}" "${nud}" "${addr}" "${dev}" "${vendor:--}"
        }

        done
    else
        echo "$(basename "${0}"): show ${@}"
        vtysh -c "show ${1} ${2} ${3} ${4} ${5}"
    fi

# IPsec
elif [[ "${1}" == "ipsec" ]]; then
    echo "$(basename "${0}"): ${@}"

    if [[ "${2}" == "det"* ]]; then
        ipsec statusall
    elif [[ "${2}" == "vti" ]]; then
        ip -s xfrm state
    elif [[ "${2}" == "ike" ]]; then
        swanctl --list-sas
    elif [[ "${2}" == "log" ]]; then
        swanctl --log
    else
        ipsec "${2:-status}"
    fi

# Interface statistics
elif [[ "${1}" == "in"* ]]; then
    echo "$(basename "${0}"): show ${@}"
    vtysh -c "show ${1} ${2} ${3}"

# LISTENING ports
elif [[ "${1}" == "listen" ]]; then
    lsof -nP -iTCP -sTCP:LISTEN

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
    lldpcli show neighbors summary

# VLAN
elif [[ "${1}" == "vlan" ]]; then
    awk -F'|' 'BEGIN{printf "%-16s %-7s %s\n", "Name", "ID", "Interface"}/\|.*\|/{printf "%-15s %-7s %s\n", $1, $2, $3}' /proc/net/vlan/config

# LOG count
elif [[ "${1}" == "syslog" ]]; then
    journalctl -o json | jq -r 'if .SYSLOG_IDENTIFIER | contains("ansible") | not then .SYSLOG_IDENTIFIER else empty end' | sort | uniq -c | sort -nr | awk 'BEGIN{printf("%6s %-25s\n", "Hits", "Service")}//{printf("%6s %-25s\n", $1, $2)}'

# Print Help
else cat << EOF
Linux script for creating a network report for visibility and debuging.
Usage: $(basename "${0}") [command]

Command:
  arp            Show arp
  dhcp           Show DHCP leases
  ip             vtysh "show ip ..." cmd pass
  ipv6           vtysh "show ipv6 ..." cmd pass
  ipsec          Show ipsec ... [detail|ike|log|vti]
  in*            vtysh "show interface ... " cmd pass
  listen         show listening ports
  lldp           show lldp neighbors
  nat            Show current nat table ... [dst|src]
  vlan           Show configured vlans

EOF
fi | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

### FINISH ###
