## getNetworkSmDeviceCellularUsageHistory # Return the client's daily cellular data usage history
# https://developer.cisco.com/meraki/api-v1/#!get-network-sm-device-cellular-usage-history

function getNetworkSmDeviceCellularUsageHistory ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return the client's daily cellular data usage history
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-sm-device-cellular-usage-history
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	deviceId: \${2} (${2:-required})
	---
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/sm/devices/${2}/cellularUsageHistory" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
