## updateNetworkAppliancePort # Update the per-port VLAN settings for a single MX port.
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-port

function updateNetworkAppliancePort ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the per-port VLAN settings for a single MX port.
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-port
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	portId: \${2} (${2:-required})
	---
	enabled: The status of the port
	dropUntaggedTraffic: Trunk port can Drop all Untagged traffic. When true, no VLAN is required. Access ports cannot have dropUntaggedTraffic set to true.
	type: The type of the port: 'access' or 'trunk'.
	vlan: Native VLAN when the port is in Trunk mode. Access VLAN when the port is in Access mode.
	allowedVlans: Comma-delimited list of the VLAN ID's allowed on the port, or 'all' to permit all VLAN's on the port.
	accessPolicy: The name of the policy. Only applicable to Access ports. Valid values are: 'open', '8021x-radius', 'mac-radius', 'hybris-radius' for MX64 or Z3 or any MX supporting the per port authentication feature. Otherwise, 'open' is the only valid value and 'open' is the default value if the field is missing.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/ports/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
