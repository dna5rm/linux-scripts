## updateNetworkWirelessAlternateManagementInterface # Update alternate management interface and device static IP
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-alternate-management-interface

function updateNetworkWirelessAlternateManagementInterface ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update alternate management interface and device static IP
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-alternate-management-interface
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	enabled: Boolean value to enable or disable alternate management interface
	vlanId: Alternate management interface VLAN, must be between 1 and 4094
	protocols: Can be one or more of the following values: 'radius', 'snmp', 'syslog' or 'ldap'
	accessPoints: Array of access point serial number and IP assignment. Note: accessPoints IP assignment is not applicable for template networks, in other words, do not put 'accessPoints' in the body when updating template networks. Also, an empty 'accessPoints' array will remove all previous static IP assignments
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/alternateManagementInterface" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
