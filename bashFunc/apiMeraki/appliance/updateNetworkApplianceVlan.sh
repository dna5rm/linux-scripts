## updateNetworkApplianceVlan # Update a VLAN
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-vlan

function updateNetworkApplianceVlan ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a VLAN
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-vlan
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	vlanId: \${2} (${2:-required})
	---
	name: The name of the VLAN
	subnet: The subnet of the VLAN
	applianceIp: The local IP of the appliance on the VLAN
	groupPolicyId: The id of the desired group policy to apply to the VLAN
	vpnNatSubnet: The translated VPN subnet if VPN and VPN subnet translation are enabled on the VLAN
	dhcpHandling: The appliance's handling of DHCP requests on this VLAN. One of: 'Run a DHCP server', 'Relay DHCP to another server' or 'Do not respond to DHCP requests'
	dhcpRelayServerIps: The IPs of the DHCP servers that DHCP requests should be relayed to
	dhcpLeaseTime: The term of DHCP leases if the appliance is running a DHCP server on this VLAN. One of: '30 minutes', '1 hour', '4 hours', '12 hours', '1 day' or '1 week'
	dhcpBootOptionsEnabled: Use DHCP boot options specified in other properties
	dhcpBootNextServer: DHCP boot option to direct boot clients to the server to load the boot file from
	dhcpBootFilename: DHCP boot option for boot filename
	fixedIpAssignments: The DHCP fixed IP assignments on the VLAN. This should be an object that contains mappings from MAC addresses to objects that themselves each contain "ip" and "name" string fields. See the sample request/response for more details.
	reservedIpRanges: The DHCP reserved IP ranges on the VLAN
	dnsNameservers: The DNS nameservers used for DHCP responses, either "upstream_dns", "google_dns", "opendns", or a newline seperated string of IP addresses or domain names
	dhcpOptions: The list of DHCP options that will be included in DHCP responses. Each object in the list should have "code", "type", and "value" properties.
	templateVlanType: Type of subnetting of the VLAN. Applicable only for template network.
	cidr: CIDR of the pool of subnets. Applicable only for template network. Each network bound to the template will automatically pick a subnet from this pool to build its own VLAN.
	mask: Mask used for the subnet of all bound to the template networks. Applicable only for template network.
	ipv6: IPv6 configuration on the VLAN
	mandatoryDhcp: Mandatory DHCP will enforce that clients connecting to this VLAN must use the IP address assigned by the DHCP server. Clients who use a static IP address won't be able to associate. Only available on firmware versions 17.0 and above
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/vlans/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
