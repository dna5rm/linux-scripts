## getNetworkBluetoothClient # Return a Bluetooth client
# https://developer.cisco.com/meraki/api-v1/#!get-network-bluetooth-client

function getNetworkBluetoothClient ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return a Bluetooth client
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-bluetooth-client
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	bluetoothClientId: \${2} (${2:-required})
	---
	includeConnectivityHistory: Include the connectivity history for this client
	connectivityHistoryTimespan: The timespan, in seconds, for the connectivityHistory data. By default 1 day, 86400, will be used.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/bluetoothClients/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
