#!/bin/env -S bash
## Meraki show interfaces script.
# Ref >> https://developer.cisco.com/meraki/api-v1/

# Enable for debuging
#set -x

## Bash functions to load.
bashFunc=(
    "boxText"
    "cacheExec"
    "containsElement"
    "y2j"
    "apiMeraki/getOrganizationNetworks"
    "apiMeraki/getNetworkDevices"
    "apiMeraki/getDeviceSwitchPorts"
    "apiMeraki/getDeviceSwitchPortsStatuses"
)

## Load bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

## Verify required commands & function requirements.
for req in curl jq python3 boxText cacheExec containsElement y2j
 do type ${req} >/dev/null 2>&1 || {
     echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
     exit 1
    }
done && umask 002

## Set script variables.
meraki_uri="https://api.meraki.com/api/v1"
auth_key="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.meraki.auth_key')"
organization_id="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.meraki.organization_id')"

## Define each TAG policy as ( "TAG" "VAR" "VALUE" )
# Common TAG: INFRASTRUCTURE
POLICY_000001=( "INFRASTRUCTURE" "status" "Connected" )
# Common TAG: FACILITIES
POLICY_000101=( "FACILITIES" "port[0]" "access" )
POLICY_000102=( "FACILITIES" "port[5]" "loop guard" )
POLICY_000102=( "FACILITIES" "port[7]" "Enforce" )
# Common TAG: NETWORK
POLICY_000201=( "NETWORK" "port[5]" "loop guard" )
POLICY_000202=( "NETWORK" "port[6]" "false" )
POLICY_000102=( "NETWORK" "port[7]" "Enforce" )
# Common TAG: USERS
POLICY_000301=( "USERS" "port[0]" "access" )
POLICY_000302=( "USERS" "port[5]" "bpdu guard" )
POLICY_000303=( "USERS" "port[6]" "true" )
# Common TAG: SERVERS
POLICY_000401=( "SERVERS" "port[0]" "access" )
POLICY_000402=( "SERVERS" "duplex" "full" )
# Common TAG: PRINTERS
POLICY_000501=( "PRINTERS" "port[0]" "access" )
# Common TAG: VISITORS
POLICY_000601=( "VISITORS" "port[0]" "access" )
POLICY_000602=( "VISITORS" "port[2]" "920" )
POLICY_000603=( "VISITORS" "port[5]" "bpdu guard" )
POLICY_000604=( "VISITORS" "port[6]" "true" )

## Load TAG policies into a netsted dirty array.
for i in $(set | awk -F'=' '/^POLICY_/{print $1}'); do
    POLICY+=( "${i}[@]" )
done

## Display help if no arguments provided.
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
    # Switch site names are always uppercase with "_sw" appended.
    network_id="$(jq --arg site "$(awk '{print toupper($1)"_sw"}' <<< ${1:0:4})" -r '.[] | select( .name == $site ).id' <(cacheExec getOrganizationNetworks ${organization_id}))"

    # Get network devices and store in array.
    cacheExec getNetworkDevices ${network_id} | jq -r '(.[] | [.name, .serial]) | @tsv' | sort | while read switch serial; do

    # Display if input matches the switch name.
    [[ "${switch^^}" == "${1^^}"* ]] && {

        ### HEADER ###
        boxText "${switch} - ${serial}"
        printf "%-4s %-15s %-7s %-16s %-8s %-10s %-35s\n" "PORT" "STATUS" "TYPE" "VLAN(s)" "DUPLEX" "SPEED" "DESCRIPTION" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

        # Get device switch ports and store in array.
        cacheExec getDeviceSwitchPortsStatuses ${serial} | jq -rc '.[] | [.portId,.enabled,.status,.isUplink,.speed,.duplex,(.cdp or .lldp)] | @csv' | sed ';s/\"//g' | while IFS=, read -r portId enabled status isUplink speed duplex discovery; do

            # Do not query port if its disabled.
            [[ "${enabled,,}" == "false" ]] && {
                # Select status indicator icon [EMPTY]
                icon="$(tput bold; tput setaf 0)$(echo -e "\u25A1")$(tput sgr0)"
            } || {

                # Query switch port configuration & store in array.

                ## Get individual port on each loop itteration. [SLOW/lots of small get requests]
                #IFS=',' read -r -a port < <(cacheExec getDeviceSwitchPort ${serial} ${portId} | jq -r '. | [.type,.name,.vlan,.voiceVlan,.allowedVlans,.stpGuard,.stormControlEnabled,.udld,.tags] | flatten | @csv' | awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", ".", $i) } 1' | sed 's/\"//g')

                ## Get all ports and select the port; rely on cacheExec. [FAST/single get request]
                IFS=',' read -r -a port < <(cacheExec getDeviceSwitchPorts ${serial} | jq -r --arg portId "${portId}" '.[] | select(.portId == $portId) | [.type,.name,.vlan,.voiceVlan,.allowedVlans,.stpGuard,.stormControlEnabled,.udld,.tags] | flatten | @csv' | awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", ".", $i) } 1' | sed 's/\"//g')

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
            printf "%s %02g %-15s %-7s %-16s %-8s %-10s %s\n" "${icon}" "${portId##*_}" "${status}" "${port[0]:--}" "$([[ "${port[0]}" == "trunk" ]] && { echo "${port[4]:0:16}"; } || { echo "${port[2]:--}/${port[3]:--}"; })" "${duplex:--}" "${speed:--}" "${port[1]:0:34}"

            ### Meraki TAG policy reporting ###
            [[ "${enabled,,}" != "false" ]] && {

                [[ ! -z "${POLICY}" ]] && {
                    echo "${port[@]:8}" | xargs -n1 | while read TAG; do

                        # Loop through nested array.
                        for ((i=0; i<${#POLICY[@]}; i++)); do

                            # Notify of policy mismatch.
                            if [[ "${TAG^^}" == "${!POLICY[i]:0:1}" ]] && [[ "$(eval echo \${${!POLICY[i]:1:1}})" != "${!POLICY[i]:2:1}" ]]; then
                                printf "     [$(tput setaf 1)%s:$(tput bold)%s$(tput sgr0)] \"%s\" != \"%s\" (%s)\n" "${POLICY[i]%%[*}" "${!POLICY[i]:0:1}" "${!POLICY[i]:1:1}" "${!POLICY[i]:2:1}" "$(eval echo \${${!POLICY[i]:1:1}})"
                            fi

                        done

                        # Notify if TAG has no policy.
                        containsElement "${TAG^^}" "${port[@]:8}" || {
                            printf "     [$(tput setaf 3)INFO:$(tput setaf 4)${TAG^^}$(tput sgr0)] Missing TAG policy\n"
                        }

                    done | sort
                }
            }

        done
    }

    done
}
