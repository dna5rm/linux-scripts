## updateNetworkWirelessSsidHotspot20 # Update the Hotspot 2.0 settings of an SSID
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-hotspot-2-0

function updateNetworkWirelessSsidHotspot20 ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the Hotspot 2.0 settings of an SSID
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-hotspot-2-0
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	---
	enabled: Whether or not Hotspot 2.0 for this SSID is enabled
	operator: Operator settings for this SSID
	venue: Venue settings for this SSID
	networkAccessType: The network type of this SSID ('Private network', 'Private network with guest access', 'Chargeable public network', 'Free public network', 'Personal device network', 'Emergency services only network', 'Test or experimental', 'Wildcard')
	domains: An array of domain names
	roamConsortOis: An array of roaming consortium OIs (hexadecimal number 3-5 octets in length)
	mccMncs: An array of MCC/MNC pairs
	naiRealms: An array of NAI realms
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/ssids/${2}/hotspot20" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
