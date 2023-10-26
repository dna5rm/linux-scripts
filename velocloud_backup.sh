#!/bin/env -S bash

### Functions ###

# External functions to load
extFunc=(
    "apiVMwareVCO/configuration_get_configuration_modules"
    "apiVMwareVCO/edge_get_edge_configuration_stack"
    "apiVMwareVCO/enterprise_get_enterprise"
    "apiVMwareVCO/enterprise_get_enterprise_configurations"
    "apiVMwareVCO/enterprise_get_enterprise_edges"
    "apiVMwareVCO/enterprise_get_enterprise_network_segments"
    "apiVMwareVCO/enterprise_get_enterprise_services"
    "apiVMwareVCO/enterprise_get_object_groups"
    "apiVMwareVCO/login_enterprise_login"
    "apiVMwareVCO/logout"
    "cache_exec"
)

# Load external functions
for func in ${extFunc[@]}; do
    if [[ ! -e "/opt/bashFunc/${func}.sh" ]]; then
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    else . "/opt/bashFunc/${func}.sh"
    fi || exit 1
done

### Verify requirements ###
for req in curl jq tput yq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done

# Read credentials from vault.
[[ -f "${HOME}/.loginrc.vault" && "${HOME}/.vaultpw" ]] && {
    vco_auth=`yq -r '.velocloud' <(ansible-vault view "${HOME}/.loginrc.vault" --vault-password-file "${HOME}/.vaultpw")`
} || {
    echo "$(basename "${0}"): Unable to get creds from vault."
    exit 1;
}

### Variables ###
vco_uri="https://vco109-usca1.velocloud.net/portal/rest"

ARCHIVE="$(dirname "${0}")" # Location for archival storage.
TARGET="$(dirname "${0}")"  # Location were live backups are stored.

# Authenticate enterprise or partner (MSP) user
login_enterprise_login

# Only run if auth cookie exist.
[[ -f "${HOME}/.cache/vco_auth.cookie" ]] && {
    # Get enterprise
    install -m 644 -D <(enterprise_get_enterprise | jq '.') "${TARGET}/enterprise.json" && {
        enterprise=( `jq -r '[.id, .name] | @tsv' "${TARGET}/enterprise.json"` )

        # Archive existing data.
        if [[ ! -z "${enterprise[1]}" ]] && [[ -d "${TARGET}/${enterprise[1]}" ]]; then
            echo "$(tput smso)$(basename "${0}") - Archive Previous$(tput rmso)"
            tar czf "${ARCHIVE}/${enterprise[1]} ($(date -d "@$(stat --format='%W' "${TARGET}/${enterprise[1]}")" +'%Y-%m-%d')).tgz" -C "${TARGET}/${enterprise[1]}" "."
            rm -rf "${TARGET}/${enterprise[1]}" 2> /dev/null
        elif [[ -z "${enterprise[1]}" ]]; then
            echo "$(tput smso)$(basename "${0}") - Something went wrong, no enterprise id!$(tput rmso)"
            exit 1;
        fi

        trap 'rm -f "${tmpFile}"' EXIT
        tmpFile=$(mktemp) || exit 1

        # Profile Configurations
        install -m 644 -D <(enterprise_get_enterprise_configurations | jq '.') "${TARGET}/${enterprise[1]}/profiles.json" && {
            echo "$(tput smso)$(basename "${0}") - Profile Configurations$(tput rmso)"

            jq -r '.[] | [.id, .name] | @tsv' "${TARGET}/${enterprise[1]}/profiles.json" | while read configurationId profileName; do
                install -m 644 -D <(configuration_get_configuration_modules `jq -c --null-input --arg id ${configurationId} '{"configurationId": $id}'` | jq '.') "${tmpFile}"

                # Extract configuration modules.
                modules=( `jq -r '.[] | [.name] | @tsv' "${tmpFile}"` )
                for module in ${modules[@]}; do
                    printf "\r> %-75s" "$(tput sgr0)${profileName}$(tput sgr0): ${module}"
                    install -m 644 -D <(jq --arg index "${index:-0}" '.[$index|tonumber]' "${tmpFile}") "${TARGET}/${enterprise[1]}/${profileName//\//-}/${module}.json"
                    let index++
                done
                printf "\r> %-75s\n" "$(tput bold)${profileName}$(tput sgr0): done."
                unset index

            done
        }

        # Edge Configurations
        install -m 644 -D <(enterprise_get_enterprise_edges | jq '.') "${TARGET}/${enterprise[1]}/edges.json" && {
            echo "$(tput smso)$(basename "${0}") - Edge Configurations$(tput rmso)"
            jq -r '.[] | [.id, .name] | @tsv' "${TARGET}/${enterprise[1]}/edges.json" | while read edgeId edgeName; do
                install -m 644 -D <(edge_get_edge_configuration_stack `jq -c --null-input --arg id ${edgeId} '{"edgeId": $id}'` | jq '.') "${tmpFile}"

                # Extract Edge modules.
                profileName="$(jq -r '.[1].name' "${tmpFile}")"
                modules=( `jq -r '[.[0]["modules"][].name] | @tsv' "${tmpFile}"` )
                for module in ${modules[@]}; do
                    printf "\r> %-75s" "$(tput bold)${edgeName}$(tput sgr0): ${module}"
                    install -m 644 -D <(jq --arg index "${index:-0}" '.[0]["modules"][$index|tonumber]' "${tmpFile}") "${TARGET}/${enterprise[1]}/${profileName//\//-}/${edgeName}/${module}.json"
                    let index++
                done
                printf "\r> %-75s\n" "$(tput bold)${edgeName}$(tput sgr0): done."
                unset index

            done
        }

        # Network Segment Configurations
        echo "$(tput smso)$(basename "${0}") - Network Segment Configurations$(tput rmso)"
        install -m 644 -D <(enterprise_get_enterprise_network_segments | jq '.') "${TARGET}/${enterprise[1]}/network_segments.json"

        # Network Service Configurations
        echo "$(tput smso)$(basename "${0}") - Network Service Configurations$(tput rmso)"
        install -m 644 -D <(enterprise_get_enterprise_services | jq '.') "${TARGET}/${enterprise[1]}/services.json"

        # Object Group Configurations
        echo "$(tput smso)$(basename "${0}") - Object Group Configurations$(tput rmso)"
        install -m 644 -D <(enterprise_get_object_groups | jq '.') "${TARGET}/${enterprise[1]}/object_groups.json"
    }

    # Logout and invalidate authorization session cookie
    echo "$(tput smso)$(basename "${0}") - Logout/Invalidate session cookie$(tput rmso)"
    logout | jq '.'
}
