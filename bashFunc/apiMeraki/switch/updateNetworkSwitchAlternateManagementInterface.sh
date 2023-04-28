## updateNetworkSwitchAlternateManagementInterface # Update the switch alternate management interface for the network
# https://developer.cisco.com/meraki/api-v1/#!update-network-switch-alternate-management-interface

function updateNetworkSwitchAlternateManagementInterface ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the switch alternate management interface for the network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-switch-alternate-management-interface
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	enabled: Boolean value to enable or disable AMI configuration. If enabled, VLAN and protocols must be set
	vlanId: Alternate management VLAN, must be between 1 and 4094
	protocols: Can be one or more of the following values: 'radius', 'snmp' or 'syslog'
	switches: Array of switch serial number and IP assignment. If parameter is present, it cannot have empty body. Note: switches parameter is not applicable for template networks, in other words, do not put 'switches' in the body when updating template networks. Also, an empty 'switches' array will remove all previous assignments
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/switch/alternateManagementInterface" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
