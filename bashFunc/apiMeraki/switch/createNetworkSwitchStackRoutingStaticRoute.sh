## createNetworkSwitchStackRoutingStaticRoute # Create a layer 3 static route for a switch stack
# https://developer.cisco.com/meraki/api-v1/#!create-network-switch-stack-routing-static-route

function createNetworkSwitchStackRoutingStaticRoute ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create a layer 3 static route for a switch stack
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-switch-stack-routing-static-route
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	switchStackId: \${2} (${2:-required})
	---
	subnet: The subnet which is routed via this static route and should be specified in CIDR notation (ex. 1.2.3.0/24)
	nextHopIp: IP address of the next hop device to which the device sends its traffic for the subnet
	name: Name or description for layer 3 static route
	advertiseViaOspfEnabled: Option to advertise static route via OSPF
	preferOverOspfRoutesEnabled: Option to prefer static route over OSPF routes
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/switch/stacks/${2}/routing/staticRoutes" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
