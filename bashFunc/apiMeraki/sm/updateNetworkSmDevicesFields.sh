## updateNetworkSmDevicesFields # Modify the fields of a device
# https://developer.cisco.com/meraki/api-v1/#!update-network-sm-devices-fields

function updateNetworkSmDevicesFields ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Modify the fields of a device
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-sm-devices-fields
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	deviceFields: The new fields of the device. Each field of this object is optional.
	wifiMac: The wifiMac of the device to be modified.
	id: The id of the device to be modified.
	serial: The serial of the device to be modified.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/sm/devices/fields" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
