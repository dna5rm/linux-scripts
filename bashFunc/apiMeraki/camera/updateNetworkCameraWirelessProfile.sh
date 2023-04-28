## updateNetworkCameraWirelessProfile # Update an existing camera wireless profile in this network.
# https://developer.cisco.com/meraki/api-v1/#!update-network-camera-wireless-profile

function updateNetworkCameraWirelessProfile ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${3}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update an existing camera wireless profile in this network.
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-camera-wireless-profile
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	wirelessProfileId: \${2} (${2:-required})
	---
	name: The name of the camera wireless profile.
	ssid: The details of the SSID config.
	identity: The identity of the wireless profile. Required for creating wireless profiles in 8021x-radius auth mode.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/camera/wirelessProfiles/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
