## createNetworkFirmwareUpgradesRollback # Rollback a Firmware Upgrade For A Network
# https://developer.cisco.com/meraki/api-v1/#!create-network-firmware-upgrades-rollback

function createNetworkFirmwareUpgradesRollback ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Rollback a Firmware Upgrade For A Network
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-firmware-upgrades-rollback
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	reasons: Reasons for the rollback
	product: Product type to rollback (if the network is a combined network)
	time: Scheduled time for the rollback
	toVersion: Version to downgrade to (if the network has firmware flexibility)
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/firmwareUpgrades/rollbacks" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
