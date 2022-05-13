#!/bin/env -S bash
# F5 Tools: Iterative Network Map by node.

# Verify script requirements.
for req in fmt jq ssh tput; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require \"${req}\" but it's not installed. Aborting."
        exit 1
    }
done

# List of Functions.
bashFunc=(
    "tmpID"
    "y2j"
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

### F5 Script ###
# Wrap cmd script into a base64 string to execute on remote system
## Be sure to escape out any '$' signs if not a local variable. ##

cmd="$(cat <<EOF | base64 -w0
# Parse F5 LTM Virtual Server detail into YAML.

# Store HA status first.
_status="\$(awk -F':' '{print \$NF}' "/var/prompt/ps1")"

## Print Hostname & HA Status
awk '{print "---\nhostname:", \$0}' "/var/prompt/hostname"
echo "status: \${_status}"

## If Active: Collect info on all virual servers
if [[ "\${_status,,}" == "active" ]]; then

    # Fetch matching nodes...
    _nodes=( \$(tmsh list ltm node address | sed ':a;N;\$!ba;s/\n//g;s/}/ }\n/g' | awk '/^ltm.*${1}/{print \$3}') )
    echo -e "nodes:\n\$(printf '  - %s\n' "\${_nodes[@]}")"

    # Fetch pools...
    _pools=( \$(for n in \${_nodes[@]}; do tmsh list ltm pool one-line | awk '/^ltm.*'''\${n}'''/{print \$3}'; done) )
    echo -e "pools:\n\$(printf '  - %s\n' "\${_pools[@]}")"

    # Fetch virtuals...
    _virtuals=( \$(for p in \${_pools[@]}; do tmsh list ltm virtual pool | sed ':a;N;\$!ba;s/\n//g;s/}/ }\n/g' | awk '/^ltm.*'''\${p}'''/{print \$3}'; done) )
    echo -e "virtuals:\n\$(printf '  - %s\n' "\${_virtuals[@]}")"

    echo "virtual:"

    ## Parse virtual server statuses
    for vs in \${_virtuals[@]}; do
        tmsh show ltm virtual "\${vs}" detail field-fmt | awk -F '[^ ].*' '{tab=length(\$1); print tab,\$0}' |\
             awk 'BEGIN {}
             /{$| destination| name| status| addr/{
                ### virtual
                if(\$1 == "0" && \$2 == "ltm") { print "  - name:", \$(NF-1) }
                else if(\$1 == "4" && \$2 == "destination") { print "    destination:", \$NF }
                else if(\$1 == "4" && \$2 == "status.availability-state") { print "    availability:", \$NF }
                else if(\$1 == "4" && \$2 == "status.enabled-state") { print "    enabled:", \$NF }
                else if(\$1 == "4" && \$2 == "status.status-reason") { \$1=""; \$2=""; sub(/  /, "", \$0); print "    status:", \$0 }
                else if(\$1 == "4" && \$NF == "{") { sub(/.*-/, "", \$2); block=\$2; print "    " block ":" }
                ### virtual block pool
                else if(block == "pools" && \$1 == "8") { print "      - name:",\$2 }
                else if(block == "pools" && \$1 == "12" && \$2 == "members") { print "        nodes:"; block="members" }
                ### virtual block pool member
                else if(block == "members" && \$1 == "16") { print "          - name:",\$2 }
                else if(block == "members" && \$1 == "20" && \$2 == "addr" && \$NF != "::") { print "            addr:",\$NF }
                else if(block == "members" && \$1 == "28" && \$2 == "status.availability-state") { print "            availability:", \$NF }
                else if(block == "members" && \$1 == "28" && \$2 == "status.enabled-state") { print "            enabled:", \$NF }
                else if(block == "members" && \$1 == "28" && \$2 == "status.status-reason") { \$1=""; \$2=""; sub(/  /, "", \$0); print "            status:", \$0 }
                ### virtual block
                else if(block == "rules" && \$1 == "8") { print "      -",\$2 }
                else if(block == "profiles" && \$1 == "8") { print "      -",\$2 }
                else if(block == "addresses" && \$1 == "8") { print "      - name:",\$2 }
                ### virtual block status
                else if(\$1 == "12" && \$2 == "status.availability-state") { print "        availability:", \$NF }
                else if(\$1 == "12" && \$2 == "status.enabled-state") { print "        enabled:", \$NF }
                else if(\$1 == "12" && \$2 == "status.status-reason") { \$1=""; \$2=""; sub(/  /, "", \$0); print "        status:", \$0 }
            }
        END {}'
    done

fi
EOF
)"

# Create a colored indicator icon.
function _indicatorIcon ()
{
    # Select status indicator icon [CIRCLE]
    if [[ "${avail,,}" == "available" ]]; then
        icon=$(echo -e "\u25CF")
    # Select status indicator icon [DIAMOND]
    elif [[ "${avail,,}" == "offline" ]]; then
        icon=$(echo -e "\u25C6")
    # Select status indicator icon [TRIANGLE]
    elif [[ "${avail,,}" == "unavailable" ]]; then
        icon=$(echo -e "\u25B2")
    # Select status indicator icon [SQUARE]
    else
        icon=$(echo -e "\u25A0")
    fi

    # Select status indicator color [BLACK]
    if [[ "${state,,}" == "disabled"* ]]; then
        echo -e "$(tput bold; tput setaf 0)${icon}$(tput sgr0)"
    # Select status indicator color [GREEN]
    elif [[ "${avail,,} ${state,,}" == "available enabled" ]]; then
        echo -e "$(tput bold; tput setaf 2)${icon}$(tput sgr0)"
    # Select status indicator color [BLUE]
    elif [[ "${avail,,} ${state,,}" == "unknown enabled" ]]; then
        echo -e "$(tput bold; tput setaf 4)${icon}$(tput sgr0)"
    # Select status indicator color [RED]
    elif [[ "${avail,,} ${state,,}" == "offline enabled" ]]; then
        echo -e "$(tput bold; tput setaf 1)${icon}$(tput sgr0)"
    # Select status indicator color [YELLOW]
    elif [[ "${state,,}" == "pending" ]]; then
        echo -e "$(tput bold; tput setaf 3)${icon}$(tput sgr0)"
    # Select status indicator color [WHITE]
    else
        echo -e "[${avail,,} ${state,,}]"
        echo -e "$(tput bold; tput setaf 7)${icon}$(tput sgr0)"
    fi
}

### MAIN ###

# Prompt if no user input filter.
[[ "${1}" == "${1#*[0-9].[0-9]}" ]] && {
    echo "$(basename "${0}") - Iterative Network Map by node IP on all F5 systems." | sed "1 s,.*,$(tput setaf 0; tput setab 7)&$(tput sgr0),"
    echo "Search: \${1} (${1:-required})

    Aborting..." | sed 's/^[ \t]*//g'
} || {
    # Glob in all F5 root SSH keys.
    # Assume the name of the key is the name of the host.
    for id in ${HOME}/.ssh/f5/*.pem; do
        f5host="$(basename "${id%%.pem}")"

        # Create useable identiy file for ssh.
        tmpID "${id}"

        # Determine target cache file of output.
        cache="${HOME}/.cache/$(basename "${0}")/${f5host}_$(echo "${@}" | md5sum -t | awk '{print $1}')"

        # Execute base64 wrapped script and store in cache if missing or older then an 60min.
        if [[ ! -f "${cache}" ]] &&  [[ `find "${cache}" -mmin +60 2>&1` ]]; then
            install -m 644 -D <(ssh -o "StrictHostKeyChecking no" -i "${tmpID}" root@${f5host} 'bash -c "$(base64 -d <<< '''${cmd}''')"') "${cache}"
        fi

        ### Generate CLI Network Map ###
        [[ "$(jq -r '.virtual | length' <(y2j < "${cache}"))" -gt 0 ]] && {
            bigip=( `jq -r '"\(.hostname) \(.status)"' <(y2j < "${cache}")` )

            # Dont create report for non-active hosts.
            [[ "${bigip[1]}" == "Active" ]] && {
                # Header w/hostname
                printf "%-80s\n" "F5: ${bigip[0]} [${bigip[1]}]" | sed "1 s,.*,$(tput setaf 0; tput setab 7)&$(tput sgr0),"
                echo

                # Display Virtual
                jq -r '.virtual[] | "\(.name) \(.destination) \(.availability) \(.enabled) \(.status)"' <(y2j < "${cache}") |\
                    while read vs addr avail state status; do

                        printf "%s\n" "$(_indicatorIcon) ${vs}"
                        printf "%-1s %s\n" "" "${addr}"
                        [[ "${avail,,}" != "available" ]] && { tput bold; tput setaf 0; printf "%-1s %s\n" "" "${status}" | fmt; tput sgr0; }

                        # Display Rules
                        jq -r --arg vs "${vs}" '.virtual[] | select(.name == $vs) | .rules[]' <(y2j < "${cache}") 2> /dev/null |\
                            while read rule; do
                                [[ ! -z "${rule}" ]] && { printf "%-1s \u25CB %s\n" "" "${rule}"; }
                            done

                        # Display Pool
                        jq -r --arg vs "${vs}" '.virtual[] | select(.name == $vs) | .pools[] | "\(.name) \(.availability) \(.enabled) \(.status)"' <(y2j < "${cache}") 2> /dev/null |\
                            while read pool avail state status; do
                                printf "%-1s %s\n" "" "$(_indicatorIcon) ${pool}"

                                # Display Nodes
                                [[ ! -z "${pool}" ]] && {
                                    jq -r --arg vs "${vs}" '.virtual[] | select(.name == $vs) | .pools[].nodes[] | "\(.name) \(.addr) \(.availability) \(.enabled) \(.status)"' <(y2j < "${cache}") |\
                                        while read node addr avail state status; do
                                            printf "%-3s %s\n" "" "$(_indicatorIcon) ${node}"
                                            [[ "${addr}" != "null" ]] && { printf "%-5s %s\n" "" "${addr}"; }
                                        done
                                }

                            done
                            echo
                    done
            }
        }

    done
}
