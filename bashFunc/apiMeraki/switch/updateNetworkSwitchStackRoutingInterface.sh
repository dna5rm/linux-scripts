## updateNetworkSwitchStackRoutingInterface # Update a layer 3 interface for a switch stack
# https://developer.cisco.com/meraki/api-v1/#!update-network-switch-stack-routing-interface

function updateNetworkSwitchStackRoutingInterface ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${4}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a layer 3 interface for a switch stack
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-switch-stack-routing-interface
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	switchStackId: \${2} (${2:-required})
	interfaceId: \${3} (${3:-required})
	---
	name: A friendly name or description for the interface or VLAN.
	subnet: The network that this routed interface is on, in CIDR notation (ex. 10.1.1.0/24).
	interfaceIp: The IP address this switch stack will use for layer 3 routing on this VLAN or subnet. This cannot be the same as the switch's management IP.
	multicastRouting: Enable multicast support if, multicast routing between VLANs is required. Options are, 'disabled', 'enabled' or 'IGMP snooping querier'.
	vlanId: The VLAN this routed interface is on. VLAN must be between 1 and 4094.
	defaultGateway: The next hop for any traffic that isn't going to a directly connected subnet or over a static route. This IP address must exist in a subnet with a routed interface.
	ospfSettings: The OSPF routing settings of the interface.
	ipv6: The IPv6 settings of the interface.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/switch/stacks/${2}/routing/interfaces/${3}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
