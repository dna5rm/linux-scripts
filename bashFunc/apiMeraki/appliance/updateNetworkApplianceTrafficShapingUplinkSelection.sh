## updateNetworkApplianceTrafficShapingUplinkSelection # Update uplink selection settings for an MX network
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-traffic-shaping-uplink-selection

function updateNetworkApplianceTrafficShapingUplinkSelection ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update uplink selection settings for an MX network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-traffic-shaping-uplink-selection
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	activeActiveAutoVpnEnabled: Toggle for enabling or disabling active-active AutoVPN
	defaultUplink: The default uplink. Must be one of: 'wan1' or 'wan2'
	loadBalancingEnabled: Toggle for enabling or disabling load balancing
	failoverAndFailback: WAN failover and failback behavior
	wanTrafficUplinkPreferences: Array of uplink preference rules for WAN traffic
	vpnTrafficUplinkPreferences: Array of uplink preference rules for VPN traffic
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/trafficShaping/uplinkSelection" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
