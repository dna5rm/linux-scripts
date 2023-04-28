## updateDeviceSwitchRoutingStaticRoute # Update a layer 3 static route for a switch
# https://developer.cisco.com/meraki/api-v1/#!update-device-switch-routing-static-route

function updateDeviceSwitchRoutingStaticRoute ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a layer 3 static route for a switch
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-device-switch-routing-static-route
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	staticRouteId: \${2} (${2:-required})
	---
	name: Name or description for layer 3 static route
	subnet: The subnet which is routed via this static route and should be specified in CIDR notation (ex. 1.2.3.0/24)
	nextHopIp: IP address of the next hop device to which the device sends its traffic for the subnet
	advertiseViaOspfEnabled: Option to advertise static route via OSPF
	preferOverOspfRoutesEnabled: Option to prefer static route over OSPF routes
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/devices/${1}/switch/routing/staticRoutes/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
