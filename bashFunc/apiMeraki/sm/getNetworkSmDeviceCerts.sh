## getNetworkSmDeviceCerts # List the certs on a device
# https://developer.cisco.com/meraki/api-v1/#!get-network-sm-device-certs

function getNetworkSmDeviceCerts ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the certs on a device
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-sm-device-certs
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	deviceId: \${2} (${2:-required})
	---
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/sm/devices/${2}/certs" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
