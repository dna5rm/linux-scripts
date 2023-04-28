## updateNetworkWirelessBluetoothSettings # Update the Bluetooth settings for a network
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-bluetooth-settings

function updateNetworkWirelessBluetoothSettings ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the Bluetooth settings for a network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-bluetooth-settings
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	scanningEnabled: Whether APs will scan for Bluetooth enabled clients.
	advertisingEnabled: Whether APs will advertise beacons.
	uuid: The UUID to be used in the beacon identifier.
	majorMinorAssignmentMode: The way major and minor number should be assigned to nodes in the network. ('Unique', 'Non-unique')
	major: The major number to be used in the beacon identifier. Only valid in 'Non-unique' mode.
	minor: The minor number to be used in the beacon identifier. Only valid in 'Non-unique' mode.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/bluetooth/settings" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
