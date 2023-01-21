#!/bin/env -S bash
## Meraki Script
# Ref >> https://developer.cisco.com/meraki/api-v1/

# Enable for debuging
# set -x

## Verify core script requirements
for req in curl jq python3
 do type ${req} >/dev/null 2>&1 || {
     echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
     exit 1
    }
done && umask 002

# Bash functions to load.
bashFunc=(
    "boxText"
    "cacheExec"
    "y2j"
    "apiMeraki/getOrganizationNetworks"
    "apiMeraki/getNetworkDevices"
    "apiMeraki/getDeviceSwitchPort"
    "apiMeraki/getDeviceSwitchPortsStatuses"
)

# Load bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        #echo "Loading: $(dirname "${0}")/bashFunc/${func}.sh"
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

# Set script variables.
meraki_uri="https://api.meraki.com/api/v1"
auth_key="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.meraki.auth_key')"
organization_id="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.meraki.organization_id')"

# Display help if no arguments provided.
[[ "${#1}" -lt "4" ]] && {

    # Display Script Banner
    tput setaf 3
    cat <<-EOF
	┏┳┓┏━╸┏━┓┏━┓╻┏ ╻ ┏━┓╻ ╻
	┃┃┃┣╸ ┣┳┛┣━┫┣┻┓┃ ┗━┓┣━┫
	╹ ╹┗━╸╹┗╸╹ ╹╹ ╹╹╹┗━┛╹ ╹
	
	EOF

    # Display Required Variables
    tput sgr0 && boxText "Script Variables..."

    cat  <<-EOF
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-missing})
	API Authorization Key: \${auth_key} (${auth_key:-missing})
	API Organization ID: \${organization_id} (${organization_id:-missing})
	
	EOF

    # Display Script Arguments
    tput sgr0 && boxText "Script Arguments..."

    cat  <<-EOF
	Device or Site Name: \${1} (${1:-required})
	
	EOF

} || {

    # Get the network id for the site.
    network_id="$(jq --arg site "$(awk '{print toupper($1)"_sw"}' <<< ${1:0:4})" -r '.[] | select( .name == $site ).id' <(cacheExec getOrganizationNetworks ${organization_id}))"

    # Get network devices and store in array.
    cacheExec getNetworkDevices ${network_id} | jq -r '(.[] | [.name, .serial]) | @tsv' | sort | while read switch serial; do

    # Display if input matches the switch name.
    [[ "${switch^^}" == "${1^^}"* ]] && {

        ### HEADER ###
        boxText "${switch} - ${serial}"
        printf "%-4s %-26s %-15s %-7s %-16s %-8s %-10s %-35s\n" "PORT" "DESCRIPTION" "STATUS" "TYPE" "VLAN(s)" "DUPLEX" "SPEED" "TAGS" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

        # Get device switch ports and store in array.
        cacheExec getDeviceSwitchPortsStatuses ${serial} | jq -rc '.[] | [.portId,.enabled,.status,.isUplink,.speed,.duplex,(.cdp or .lldp)] | @csv' | sed ';s/\"//g' | while IFS=, read -r portId enabled status isUplink speed duplex discovery; do

            # Do not query port if its disabled.
            [[ "${enabled,,}" == "false" ]] && {
                # Select status indicator icon [EMPTY]
                icon="$(tput bold; tput setaf 0)$(echo -e "\u25A1")$(tput sgr0)"
            } || {

                # Query switch port configuration & store in array.
                IFS=',' read -r -a port < <(cacheExec getDeviceSwitchPort ${serial} ${portId} | jq -r '. | [.type,.name,.vlan,.voiceVlan,.allowedVlans,.stpGuard,.stormControlEnabled,.tags] | flatten | @csv' | awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", ".", $i) } 1' | sed ';s/\"//g')

                # Select status indicator icon [DIAMOND]
                if [[ "${discovery,,}" == "true" ]]; then
                    icon=$(echo -e "\u25C6")
                # Select status indicator icon [TRIANGLE]
                elif [[ "${isUplink,,}" == "true" ]]; then
                    icon=$(echo -e "\u25B2")
                # Select status indicator icon [CIRCLE]
                elif [[ "${status,,}" == "connected" ]]; then
                    icon=$(echo -e "\u25CF")
                # Select status indicator icon [SQUARE]
                else
                    icon=$(echo -e "\u25A0")
                fi

                # Select status indicator color [BLACK]
                if [[ "${status,,}" == "disconnected" ]]; then
                    icon="$(tput bold; tput setaf 0)${icon}$(tput sgr0)"
                # Select status indicator color [GREEN]
                elif [[ "${status,,}" == "connected" ]]; then
                    icon="$(tput bold; tput setaf 2)${icon}$(tput sgr0)"
                else
                    icon="$(tput bold; tput setaf 7)${icon}$(tput sgr0)"
                fi

            }

            ### BODY ###
            printf "%s %02g %-26s %-15s %-7s %-16s %-8s %-10s %s\n" "${icon}" "${portId##*_}" "${port[1]:0:25}" "${status}" "${port[0]:--}" "$([[ "${port[0]}" == "trunk" ]] && { echo "${port[4]:0:16}"; } || { echo "${port[2]:--}/${port[3]:--}"; })" "${duplex:--}" "${speed:--}" "$(echo "[$(for i in $(echo {7..15}); do [[ ! -z "${port[${i}]}" ]] && { printf "%s " "${port[${i}]^^}"; }; done | sed 's/ $//g;s/ /,/g')]" | sed '/\[]/d')"

        done
    }
    done
}
