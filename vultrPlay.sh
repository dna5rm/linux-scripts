#!/bin/env -S bash

bashFunc=(
    "boxText"
    "cacheExec"
    "selfGeoIP"
    "y2j"
    "apiVultr/get_instances"
    "apiVultr/get_domains"
    "apiVultr/get_domains_records"
    "apiVultr/post_domains_records"
    "apiVultr/get_ssh-keys"
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

vultr_auth="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.vultr')"
vultr_uri="https://api.vultr.com/v2"

# cacheExec get_instances |\
# jq -r '.[] | "\(.hostname) \(.main_ip) \(.v6_main_ip)"'

cacheExec get_ssh-keys
