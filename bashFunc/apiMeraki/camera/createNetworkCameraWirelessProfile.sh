## createNetworkCameraWirelessProfile # Creates a new camera wireless profile for this network.
# https://developer.cisco.com/meraki/api-v1/#!create-network-camera-wireless-profile

function createNetworkCameraWirelessProfile ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Creates a new camera wireless profile for this network.
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-camera-wireless-profile
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	name: The name of the camera wireless profile. This parameter is required.
	ssid: The details of the SSID config.
	identity: The identity of the wireless profile. Required for creating wireless profiles in 8021x-radius auth mode.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/camera/wirelessProfiles" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
