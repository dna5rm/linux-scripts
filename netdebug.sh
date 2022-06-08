#!/bin/env -S bash
# Adhoc script for creating network debug reports for troubleshooting.

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

# Script Functions..
function nattable ()
{
    # Return a formatted nat translation table
    sudo conntrack -L -n --output xml 2> /dev/null | x2j | jq -r '.conntrack.flow[].meta | "\(.[2].id) \(.[0].layer4."@protoname") \(.[0].layer3.src) \(.[0].layer3.dst +":"+ .[0].layer4.dport) \(.[2].use)"'
}

### BEGIN ###

# NAT Table
if [[ "${1}" == "nat" ]]; then
    nattable | awk 'BEGIN{printf("%-12s %-6s %-18s %-23s %s\n", "ID", "Proto", "Source", "Destination", "Use" )}//{printf("%-12s %-6s %-18s %-23s %s\n", $1, $2, $3, $4, $5)}'

# NAT: Top destinations
elif [[ "${1}" == "natdst" ]]; then
    nattable | awk '/^[0-9]/{print $4}' | sort | uniq -c | sort -nr | while read line; do
        echo "${line} $(awk '/[\t| ]'''${line##*:}'''\//{print $1; exit}' /etc/services)"
    done | awk 'BEGIN{printf("%6s %-23s %-15s\n", "Hits", "Destination", "Service")}//{printf("%6s %-23s %-15s\n", $1, $2, $3)}'

# NAT: Top sources
elif [[ "${1}" == "natsrc" ]]; then
    nattable | awk '/^[0-9]/{print $3}' | sort | uniq -c | sort -nr |\
        awk 'BEGIN{printf("%6s %-18s\n", "Hits", "Source")}//{printf("%6s %-18s\n", $1, $2)}'

# Print Help
else cat << EOF
Linux script for creating a network report for visibility and debuging.
Usage: $(basename "${0}") [command]

Command:
  nat            List current nat table
  natdst         List top destinations in nat table.
  natsrc         List top sources in nat table

EOF
fi | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

### FINISH ###
