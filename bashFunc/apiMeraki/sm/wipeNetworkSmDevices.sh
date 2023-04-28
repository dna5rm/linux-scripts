## wipeNetworkSmDevices # Wipe a device
# https://developer.cisco.com/meraki/api-v1/#!wipe-network-sm-devices

function wipeNetworkSmDevices ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Wipe a device
	Ref: https://developer.cisco.com/meraki/api-v1/#!wipe-network-sm-devices
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	wifiMac: The wifiMac of the device to be wiped.
	id: The id of the device to be wiped.
	serial: The serial of the device to be wiped.
	pin: The pin number (a six digit value) for wiping a macOS device. Required only for macOS devices.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/sm/devices/wipe" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
