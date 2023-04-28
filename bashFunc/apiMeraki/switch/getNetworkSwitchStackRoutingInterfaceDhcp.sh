## getNetworkSwitchStackRoutingInterfaceDhcp # Return a layer 3 interface DHCP configuration for a switch stack
# https://developer.cisco.com/meraki/api-v1/#!get-network-switch-stack-routing-interface-dhcp

function getNetworkSwitchStackRoutingInterfaceDhcp ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return a layer 3 interface DHCP configuration for a switch stack
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-switch-stack-routing-interface-dhcp
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	switchStackId: \${2} (${2:-required})
	interfaceId: \${3} (${3:-required})
	---
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/switch/stacks/${2}/routing/interfaces/${3}/dhcp" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
