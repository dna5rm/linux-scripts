## updateNetworkSwitchStackRoutingInterfaceDhcp # Update a layer 3 interface DHCP configuration for a switch stack
# https://developer.cisco.com/meraki/api-v1/#!update-network-switch-stack-routing-interface-dhcp

function updateNetworkSwitchStackRoutingInterfaceDhcp ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${4}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a layer 3 interface DHCP configuration for a switch stack
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-switch-stack-routing-interface-dhcp
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	switchStackId: \${2} (${2:-required})
	interfaceId: \${3} (${3:-required})
	---
	dhcpMode: The DHCP mode options for the switch stack interface ('dhcpDisabled', 'dhcpRelay' or 'dhcpServer')
	dhcpRelayServerIps: The DHCP relay server IPs to which DHCP packets would get relayed for the switch stack interface
	dhcpLeaseTime: The DHCP lease time config for the dhcp server running on switch stack interface ('30 minutes', '1 hour', '4 hours', '12 hours', '1 day' or '1 week')
	dnsNameserversOption: The DHCP name server option for the dhcp server running on the switch stack interface ('googlePublicDns', 'openDns' or 'custom')
	dnsCustomNameservers: The DHCP name server IPs when DHCP name server option is 'custom'
	bootOptionsEnabled: Enable DHCP boot options to provide PXE boot options configs for the dhcp server running on the switch stack interface
	bootNextServer: The PXE boot server IP for the DHCP server running on the switch stack interface
	bootFileName: The PXE boot server file name for the DHCP server running on the switch stack interface
	dhcpOptions: Array of DHCP options consisting of code, type and value for the DHCP server running on the switch stack interface
	reservedIpRanges: Array of DHCP reserved IP assignments for the DHCP server running on the switch stack interface
	fixedIpAssignments: Array of DHCP fixed IP assignments for the DHCP server running on the switch stack interface
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/switch/stacks/${2}/routing/interfaces/${3}/dhcp" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
