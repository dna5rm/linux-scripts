#!/bin/env -S bash
# F5 Tools: Display a table of all F5 systems.

# Verify script requirements.
for req in jq ssh; do
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
# Return YAML of F5 system info

## Hostname of the F5
awk '{print "---\nhostname:", \$0}' "/var/prompt/hostname"

## HA status of the F5
awk -F':' '{print "status:", \$NF}' "/var/prompt/ps1"

## Parse hardware information
tmsh show sys hardware field-fmt | sed -n -e '/[platform|info] {$/,/^}$/p' | awk 'BEGIN {}
/^sys|versions|marketing-name|mac|serial|platform/ {
    if(\$NF == "{") { sys=\$(NF-1) }
    else if(\$1 ~ /versions.[0-9].name/) { \$1=""; name=\$0 }
    else if(sys == "host_platform" && name == " Host platform name") { name=""; print "type:", \$NF }
    else if(sys == "platform" && \$1 == "base-mac") { print "basemac:", \$NF }
    else if(sys == "platform" && \$1 == "marketing-name") { sub(/.*marketing-name /, "", \$0); print "name:", \$0 }
    else if(sys == "system-info" && \$1 == "bigip-chassis-serial-num") { print "chassissn:", \$NF }
    else if(sys == "system-info" && \$1 == "host-board-serial-num") { print "hostsn:", \$NF }
    else if(sys == "system-info" && \$1 == "platform") { print "platform:", \$NF }
}'

## Parse version info
tmsh show sys version | awk '//{
    if(\$1 == "Version") {print "version:", \$NF}
    else if(\$1 == "Build") {print "build:", \$NF}
}'
EOF
)"

### MAIN ###

FORMAT="%-20s %-7s %-25s %-9s %-9s %-31s\n"
printf "${FORMAT}" "Appliance" "Type" "Platform" "Version" "Build" "Chassis Serial" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

for id in ${HOME}/.ssh/f5/*.pem; do
    f5host="$(basename ${id%%.pem})"

    # Create useable identiy file for ssh.
    tmpID "${id}"

    # Run Commands.
    json=`ssh -o "StrictHostKeyChecking no" -i "${tmpID}" root@${f5host} 'bash -c "$(base64 -d <<< '''${cmd}''')"' | y2j`

    # Display Table Row.
    printf "${FORMAT}" \
        "$(jq -jr '.hostname' <<< "${json:-\{\}}")" \
        "$(jq -jr '.platform' <<< "${json:-\{\}}")" \
        "$(jq -jr '.name' <<< "${json:-\{\}}")" \
        "$(jq -jr '.version' <<< "${json:-\{\}}")" \
        "$(jq -jr '.build' <<< "${json:-\{\}}")" \
        "$(jq -jr '.chassissn' <<< "${json:-\{\}}")"

done
