#!/bin/env -S bash
## Meraki show interfaces script.
# Ref >> https://developer.cisco.com/meraki/api-v1/

## Bash functions to load.
bashFunc=(
    # Core Functions
    "box_text"
    "cache_exec"
    "contains_element"
    "apiMeraki/getOrganizations"
    "apiMeraki/getOrganizationNetworks"
    "apiMeraki/getNetworkDevices"
    # Optional Functions - Switch
    "apiMeraki/getDeviceSwitchPorts"
    "apiMeraki/getDeviceSwitchPortsStatuses"
    "apiMeraki/getDeviceSwitchRoutingInterfaces"
    "apiMeraki/getDeviceSwitchRoutingInterfaces"
    "apiMeraki/getDeviceSwitchRoutingStaticRoutes"
    "apiMeraki/getNetworkSwitchAccessControlLists"
    "apiMeraki/getNetworkSwitchAccessPolicies"
    "apiMeraki/getNetworkSwitchAlternateManagementInterface"
    "apiMeraki/getNetworkSwitchDhcpServerPolicy"
    "apiMeraki/getNetworkSwitchDhcpServerPolicyArpInspectionTrustedServers"
    "apiMeraki/getNetworkSwitchDhcpV4ServersSeen"
    "apiMeraki/getNetworkSwitchDscpToCosMappings"
    "apiMeraki/getNetworkSwitchLinkAggregations"
    "apiMeraki/getNetworkSwitchMtu"
    "apiMeraki/getNetworkSwitchPortSchedules"
    "apiMeraki/getNetworkSwitchQosRules"
    "apiMeraki/getNetworkSwitchRoutingMulticast"
    "apiMeraki/getNetworkSwitchRoutingMulticastRendezvousPoints"
    "apiMeraki/getNetworkSwitchRoutingOspf"
    "apiMeraki/getNetworkSwitchSettings"
    "apiMeraki/getNetworkSwitchStackRoutingInterfaces"
    "apiMeraki/getNetworkSwitchStacks"
    "apiMeraki/getNetworkSwitchStormControl"
    "apiMeraki/getNetworkSwitchStp"
    # Optional Functions - Wireless
#   "apiMeraki/getDeviceWirelessBluetoothSettings"
#   "apiMeraki/getDeviceWirelessRadioSettings"
    "apiMeraki/getNetworkWirelessAlternateManagementInterface"
    "apiMeraki/getNetworkWirelessBilling"
    "apiMeraki/getNetworkWirelessBluetoothSettings"
    "apiMeraki/getNetworkWirelessRfProfiles"
    "apiMeraki/getNetworkWirelessSettings"
    "apiMeraki/getNetworkWirelessSsids"
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
for req in curl jq python3 box_text cache_exec contains_element yq
 do type ${req} >/dev/null 2>&1 || {
     echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
     exit 1
    }
done && umask 002

# Read credentials from vault.
[[ -f "${HOME}/.loginrc.vault" && "${HOME}/.vaultpw" ]] && {
    auth_key=`yq -r '.meraki.auth_key' <(ansible-vault view "${HOME}/.loginrc.vault" --vault-password-file "${HOME}/.vaultpw")`
} || {
    echo "$(basename "${0}"): Unable to get creds from vault."
    exit 1;
}

## Set script variables.
meraki_uri="https://api.meraki.com/api/v1"

TARGET="$(dirname "${0}")"

# List the organizations that the auth_key has privileges on.
install -m 644 -D <(cache_exec getOrganizations | jq '.') "${TARGET}/getOrganizations.json" && {
    jq -r '.[] | select(.api.enabled) | [.id, .name] | @tsv' "${TARGET}/getOrganizations.json" | while read org_id org_name; do

        # Archive existing data if older then 24 hours.
        [[ $(find "${TARGET}/${org_name}" -maxdepth 0 -mtime +1 -print) ]] && {
            tar czf "${TARGET}/${org_name} ($(date -d "@$(stat --format='%W' "${TARGET}/${org_name}")" +'%Y-%m-%d')).tgz" -C "${TARGET}/${org_name}" "."
            rm -rf "${TARGET}/${org_name}" || {
                echo "$(basename "${0}") - Unable to remove stale target directory.";
                exit 1;
            }
        }

        # List the networks in the organization.
        install -m 644 -D  <(cache_exec getOrganizationNetworks ${org_id} | jq '.') "${TARGET}/${org_name}/getOrganizationNetworks.json" && {
            jq -r '(.[] | [.id, .name]) | @tsv' "${TARGET}/${org_name}/getOrganizationNetworks.json" | while read net_id net_name; do

                # List the devices in a network
                install -m 644 -D  <(cache_exec getNetworkDevices ${net_id} | jq '.') "${TARGET}/${org_name}/${net_name}/getNetworkDevices.json" && {
                    jq -r '(.[] | [.serial, .name, .model]) | @tsv' "${TARGET}/${org_name}/${net_name}/getNetworkDevices.json" | while read serial name model; do

                         echo "${name^^} (${serial})"

                         ### Device Type: Network Switches
                         if [[ "${model^^}" = "MS"* ]]; then

                             # List loaded functions in reverse order dependant functions get read last.
                             declare -F | awk '/getNetworkSwitch/{print $NF}' | sort -r | while read TASK; do
                                 # Fetch getNetworkSwitch functions for site (run once).
                                 if [[ $(type -t ${TASK}) == "function" ]] && \
                                    [[ "${TASK}" != "getNetworkSwitchStackRoutingInterfaces" ]] && \
                                    [[ ! -e  "${TARGET}/${org_name}/${net_name}/${TASK}.json" ]]; then
                                     install -m 644 -D  <(cache_exec ${TASK} ${net_id} | jq '.') "${TARGET}/${org_name}/${net_name}/${TASK}.json"

                                 # Fetch getNetworkSwitchStacks tasks for site (run once).
                                 elif [[ $(type -t ${TASK}) == "function" ]] && \
                                      [[ -e  "${TARGET}/${org_name}/${net_name}/getNetworkSwitchStacks.json" ]] && \
                                      [[ "${TASK}" == "getNetworkSwitchStackRoutingInterfaces" ]]; then

                                     # List the device stacks in a network
                                     jq -r '.[] | [.id, .name] | @tsv' "${TARGET}/${org_name}/${net_name}/getNetworkSwitchStacks.json" | while read stack_id stack_name; do
                                         install -m 644 -D  <(cache_exec ${TASK} ${net_id} ${stack_id} | jq '.') "${TARGET}/${org_name}/${net_name}/${stack_name^^}.${TASK}.json"
                                     done
                                 fi
                             done

                             # Fetch getDeviceSwitch functions for each serial.
                             declare -F | awk '/getDeviceSwitch/{print $NF}' | while read TASK; do
                                 if [[ $(type -t ${TASK}) == "function" ]] && \
                                    [[ ! -e  "${TARGET}/${org_name}/${net_name}/${name^^}.${TASK}.json" ]]; then
                                     install -m 644 -D  <(cache_exec ${TASK} ${serial} | jq '.') "${TARGET}/${org_name}/${net_name}/${name^^}.${TASK}.json"
                                 fi
                             done

                         ### Device Type: Wireless
                         elif [[ "${model^^}" = "MR"* ]]; then

                             # List loaded functions in reverse order dependant functions get read last.
                             declare -F | awk '/getNetworkWireless/{print $NF}' | sort -r | while read TASK; do
                                 # Fetch getNetworkWireless functions for site (run once).
                                 if [[ $(type -t ${TASK}) == "function" ]] && \
                                    [[ ! -e  "${TARGET}/${org_name}/${net_name}/${TASK}.json" ]]; then
                                     install -m 644 -D  <(cache_exec ${TASK} ${net_id} | jq '.') "${TARGET}/${org_name}/${net_name}/${TASK}.json"
                                 fi
                             done

                             # Fetch getDeviceWireless functions for each serial.
                             declare -F | awk '/getDeviceWireless/{print $NF}' | while read TASK; do
                                 if [[ $(type -t ${TASK}) == "function" ]] && \
                                    [[ ! -e  "${TARGET}/${org_name}/${net_name}/${name^^}.${TASK}.json" ]]; then
                                     install -m 644 -D  <(cache_exec ${TASK} ${serial} | jq '.') "${TARGET}/${org_name}/${net_name}/${name^^}.${TASK}.json"
                                 fi
                             done


                         fi
                         ### Device Type: Finished

                    done
                }

            done
        }

    done
}
