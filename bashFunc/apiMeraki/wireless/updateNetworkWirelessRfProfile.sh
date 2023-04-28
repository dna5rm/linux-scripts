## updateNetworkWirelessRfProfile # Updates specified RF profile for this network
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-rf-profile

function updateNetworkWirelessRfProfile ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Updates specified RF profile for this network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-rf-profile
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	rfProfileId: \${2} (${2:-required})
	---
	name: The name of the new profile. Must be unique.
	clientBalancingEnabled: Steers client to best available access point. Can be either true or false.
	minBitrateType: Minimum bitrate can be set to either 'band' or 'ssid'.
	bandSelectionType: Band selection can be set to either 'ssid' or 'ap'.
	apBandSettings: Settings that will be enabled if selectionType is set to 'ap'.
	twoFourGhzSettings: Settings related to 2.4Ghz band
	fiveGhzSettings: Settings related to 5Ghz band
	transmission: Settings related to radio transmission.
	perSsidSettings: Per-SSID radio settings by number.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/rfProfiles/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
