## updateNetworkApplianceFirewallFirewalledService # Updates the accessibility settings for the given service ('ICMP', 'web', or 'SNMP')
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-firewall-firewalled-service

function updateNetworkApplianceFirewallFirewalledService ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Updates the accessibility settings for the given service ('ICMP', 'web', or 'SNMP')
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-firewall-firewalled-service
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	service: \${2} (${2:-required})
	---
	access: A string indicating the rule for which IPs are allowed to use the specified service. Acceptable values are "blocked" (no remote IPs can access the service), "restricted" (only allowed IPs can access the service), and "unrestriced" (any remote IP can access the service). This field is required
	allowedIps: An array of allowed IPs that can access the service. This field is required if "access" is set to "restricted". Otherwise this field is ignored
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/firewall/firewalledServices/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
