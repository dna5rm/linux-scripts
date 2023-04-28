## createNetworkApplianceVlan # Add a VLAN
# https://developer.cisco.com/meraki/api-v1/#!create-network-appliance-vlan

function createNetworkApplianceVlan ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Add a VLAN
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-appliance-vlan
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	id: The VLAN ID of the new VLAN (must be between 1 and 4094)
	name: The name of the new VLAN
	subnet: The subnet of the VLAN
	applianceIp: The local IP of the appliance on the VLAN
	groupPolicyId: The id of the desired group policy to apply to the VLAN
	templateVlanType: Type of subnetting of the VLAN. Applicable only for template network.
	cidr: CIDR of the pool of subnets. Applicable only for template network. Each network bound to the template will automatically pick a subnet from this pool to build its own VLAN.
	mask: Mask used for the subnet of all bound to the template networks. Applicable only for template network.
	ipv6: IPv6 configuration on the VLAN
	mandatoryDhcp: Mandatory DHCP will enforce that clients connecting to this VLAN must use the IP address assigned by the DHCP server. Clients who use a static IP address won't be able to associate. Only available on firmware versions 17.0 and above
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/appliance/vlans" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
