## createNetworkFirmwareUpgradesStagedEvent # Create a Staged Upgrade Event for a network
# https://developer.cisco.com/meraki/api-v1/#!create-network-firmware-upgrades-staged-event

function createNetworkFirmwareUpgradesStagedEvent ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${2}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create a Staged Upgrade Event for a network
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-firmware-upgrades-staged-event
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	stages: All firmware upgrade stages in the network with their start time.
	products: Contains firmware upgrade version information
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/firmwareUpgrades/staged/events" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
