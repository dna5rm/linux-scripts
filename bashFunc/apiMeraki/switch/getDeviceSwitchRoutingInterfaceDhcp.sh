## getDeviceSwitchRoutingInterfaceDhcp # Return a layer 3 interface DHCP configuration for a switch
# https://developer.cisco.com/meraki/api-v1/#!get-device-switch-routing-interface-dhcp

function getDeviceSwitchRoutingInterfaceDhcp ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return a layer 3 interface DHCP configuration for a switch
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-device-switch-routing-interface-dhcp
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	interfaceId: \${2} (${2:-required})
	---
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/devices/${1}/switch/routing/interfaces/${2}/dhcp" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
