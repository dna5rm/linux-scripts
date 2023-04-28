## updateNetworkApplianceSsid # Update the attributes of an MX SSID
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-ssid

function updateNetworkApplianceSsid ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the attributes of an MX SSID
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-ssid
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	---
	name: The name of the SSID.
	enabled: Whether or not the SSID is enabled.
	defaultVlanId: The VLAN ID of the VLAN associated to this SSID. This parameter is only valid if the network is in routed mode.
	authMode: The association control method for the SSID ('open', 'psk', '8021x-meraki' or '8021x-radius').
	psk: The passkey for the SSID. This param is only valid if the authMode is 'psk'.
	radiusServers: The RADIUS 802.1x servers to be used for authentication. This param is only valid if the authMode is '8021x-radius'.
	encryptionMode: The psk encryption mode for the SSID ('wep' or 'wpa'). This param is only valid if the authMode is 'psk'.
	wpaEncryptionMode: The types of WPA encryption. ('WPA1 and WPA2', 'WPA2 only', 'WPA3 Transition Mode' or 'WPA3 only'). This param is only valid if (1) the authMode is 'psk' & the encryptionMode is 'wpa' OR (2) the authMode is '8021x-meraki' OR (3) the authMode is '8021x-radius'
	visible: Boolean indicating whether the MX should advertise or hide this SSID.
	dhcpEnforcedDeauthentication: DHCP Enforced Deauthentication enables the disassociation of wireless clients in addition to Mandatory DHCP. This param is only valid on firmware versions >= MX 17.0 where the associated LAN has Mandatory DHCP Enabled 
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/ssids/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
