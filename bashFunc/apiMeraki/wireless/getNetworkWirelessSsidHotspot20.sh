## getNetworkWirelessSsidHotspot20 # Return the Hotspot 2.0 settings for an SSID
# https://developer.cisco.com/meraki/api-v1/#!get-network-wireless-ssid-hotspot-2-0

function getNetworkWirelessSsidHotspot20 ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return the Hotspot 2.0 settings for an SSID
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-wireless-ssid-hotspot-2-0
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	---
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/wireless/ssids/${2}/hotspot20" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
