## updateDeviceSwitchRoutingInterfaceDhcp # Update a layer 3 interface DHCP configuration for a switch
# https://developer.cisco.com/meraki/api-v1/#!update-device-switch-routing-interface-dhcp

function updateDeviceSwitchRoutingInterfaceDhcp ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a layer 3 interface DHCP configuration for a switch
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-device-switch-routing-interface-dhcp
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	interfaceId: \${2} (${2:-required})
	---
	dhcpMode: The DHCP mode options for the switch interface ('dhcpDisabled', 'dhcpRelay' or 'dhcpServer')
	dhcpRelayServerIps: The DHCP relay server IPs to which DHCP packets would get relayed for the switch interface
	dhcpLeaseTime: The DHCP lease time config for the dhcp server running on switch interface ('30 minutes', '1 hour', '4 hours', '12 hours', '1 day' or '1 week')
	dnsNameserversOption: The DHCP name server option for the dhcp server running on the switch interface ('googlePublicDns', 'openDns' or 'custom')
	dnsCustomNameservers: The DHCP name server IPs when DHCP name server option is 'custom'
	bootOptionsEnabled: Enable DHCP boot options to provide PXE boot options configs for the dhcp server running on the switch interface
	bootNextServer: The PXE boot server IP for the DHCP server running on the switch interface
	bootFileName: The PXE boot server filename for the DHCP server running on the switch interface
	dhcpOptions: Array of DHCP options consisting of code, type and value for the DHCP server running on the switch interface
	reservedIpRanges: Array of DHCP reserved IP assignments for the DHCP server running on the switch interface
	fixedIpAssignments: Array of DHCP fixed IP assignments for the DHCP server running on the switch interface
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/devices/${1}/switch/routing/interfaces/${2}/dhcp" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
