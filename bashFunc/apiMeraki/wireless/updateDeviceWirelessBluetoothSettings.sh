## updateDeviceWirelessBluetoothSettings # Update the bluetooth settings for a wireless device
# https://developer.cisco.com/meraki/api-v1/#!update-device-wireless-bluetooth-settings

function updateDeviceWirelessBluetoothSettings ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the bluetooth settings for a wireless device
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-device-wireless-bluetooth-settings
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	uuid: Desired UUID of the beacon. If the value is set to null it will reset to Dashboard's automatically generated value.
	major: Desired major value of the beacon. If the value is set to null it will reset to Dashboard's automatically generated value.
	minor: Desired minor value of the beacon. If the value is set to null it will reset to Dashboard's automatically generated value.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/devices/${1}/wireless/bluetooth/settings" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
