## getNetworkPiiPiiKeys # List the keys required to access Personally Identifiable Information (PII) for a given identifier
# https://developer.cisco.com/meraki/api-v1/#!get-network-pii-pii-keys

function getNetworkPiiPiiKeys ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the keys required to access Personally Identifiable Information (PII) for a given identifier
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-pii-pii-keys
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	username: The username of a Systems Manager user
	email: The email of a network user account or a Systems Manager device
	mac: The MAC of a network client device or a Systems Manager device
	serial: The serial of a Systems Manager device
	imei: The IMEI of a Systems Manager device
	bluetoothMac: The MAC of a Bluetooth client
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/pii/piiKeys" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
