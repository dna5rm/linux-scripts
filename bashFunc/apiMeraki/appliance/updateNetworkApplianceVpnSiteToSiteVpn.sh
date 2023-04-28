## updateNetworkApplianceVpnSiteToSiteVpn # Update the site-to-site VPN settings of a network
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-vpn-site-to-site-vpn

function updateNetworkApplianceVpnSiteToSiteVpn ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the site-to-site VPN settings of a network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-vpn-site-to-site-vpn
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	mode: The site-to-site VPN mode. Can be one of 'none', 'spoke' or 'hub'
	hubs: The list of VPN hubs, in order of preference. In spoke mode, at least 1 hub is required.
	subnets: The list of subnets and their VPN presence.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/vpn/siteToSiteVpn" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
