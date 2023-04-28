## updateNetworkWirelessSsidVpn # Update the VPN settings for the SSID
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-vpn

function updateNetworkWirelessSsidVpn ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the VPN settings for the SSID
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-vpn
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	---
	concentrator: The VPN concentrator settings for this SSID.
	splitTunnel: The VPN split tunnel settings for this SSID.
	failover: Secondary VPN concentrator settings. This is only used when two VPN concentrators are configured on the SSID.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/ssids/${2}/vpn" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
