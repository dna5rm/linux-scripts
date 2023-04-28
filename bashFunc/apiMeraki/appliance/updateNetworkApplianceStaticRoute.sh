## updateNetworkApplianceStaticRoute # Update a static route for an MX or teleworker network
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-static-route

function updateNetworkApplianceStaticRoute ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a static route for an MX or teleworker network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-static-route
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	staticRouteId: \${2} (${2:-required})
	---
	name: The name of the static route
	subnet: The subnet of the static route
	gatewayIp: The gateway IP (next hop) of the static route
	gatewayVlanId: The gateway IP (next hop) VLAN ID of the static route
	enabled: The enabled state of the static route
	fixedIpAssignments: The DHCP fixed IP assignments on the static route. This should be an object that contains mappings from MAC addresses to objects that themselves each contain "ip" and "name" string fields. See the sample request/response for more details.
	reservedIpRanges: The DHCP reserved IP ranges on the static route
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/staticRoutes/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
