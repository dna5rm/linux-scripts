## updateNetworkFirmwareUpgradesStagedGroup # Update a Staged Upgrade Group for a network
# https://developer.cisco.com/meraki/api-v1/#!update-network-firmware-upgrades-staged-group

function updateNetworkFirmwareUpgradesStagedGroup ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${3}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a Staged Upgrade Group for a network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-firmware-upgrades-staged-group
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	groupId: \${2} (${2:-required})
	---
	name: Name of the Staged Upgrade Group. Length must be 1 to 255 characters
	isDefault: Boolean indicating the default Group. Any device that does not have a group explicitly assigned will upgrade with this group
	description: Description of the Staged Upgrade Group. Length must be 1 to 255 characters
	assignedDevices: The devices and Switch Stacks assigned to the Group
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/firmwareUpgrades/staged/groups/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
