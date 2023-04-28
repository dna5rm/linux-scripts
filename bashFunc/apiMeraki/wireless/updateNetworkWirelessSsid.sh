## updateNetworkWirelessSsid # Update the attributes of an MR SSID
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid

function updateNetworkWirelessSsid ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the attributes of an MR SSID
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	---
	name: The name of the SSID
	enabled: Whether or not the SSID is enabled
	authMode: The association control method for the SSID ('open', 'open-enhanced', 'psk', 'open-with-radius', 'open-with-nac', '8021x-meraki', '8021x-nac', '8021x-radius', '8021x-google', '8021x-localradius', 'ipsk-with-radius' or 'ipsk-without-radius')
	enterpriseAdminAccess: Whether or not an SSID is accessible by 'enterprise' administrators ('access disabled' or 'access enabled')
	encryptionMode: The psk encryption mode for the SSID ('wep' or 'wpa'). This param is only valid if the authMode is 'psk'
	psk: The passkey for the SSID. This param is only valid if the authMode is 'psk'
	wpaEncryptionMode: The types of WPA encryption. ('WPA1 only', 'WPA1 and WPA2', 'WPA2 only', 'WPA3 Transition Mode', 'WPA3 only' or 'WPA3 192-bit Security')
	dot11w: The current setting for Protected Management Frames (802.11w).
	dot11r: The current setting for 802.11r
	splashPage: The type of splash page for the SSID ('None', 'Click-through splash page', 'Billing', 'Password-protected with Meraki RADIUS', 'Password-protected with custom RADIUS', 'Password-protected with Active Directory', 'Password-protected with LDAP', 'SMS authentication', 'Systems Manager Sentry', 'Facebook Wi-Fi', 'Google OAuth', 'Sponsored guest', 'Cisco ISE' or 'Google Apps domain'). This attribute is not supported for template children.
	splashGuestSponsorDomains: Array of valid sponsor email domains for sponsored guest splash type.
	oauth: The OAuth settings of this SSID. Only valid if splashPage is 'Google OAuth'.
	localRadius: The current setting for Local Authentication, a built-in RADIUS server on the access point. Only valid if authMode is '8021x-localradius'.
	ldap: The current setting for LDAP. Only valid if splashPage is 'Password-protected with LDAP'.
	activeDirectory: The current setting for Active Directory. Only valid if splashPage is 'Password-protected with Active Directory'
	radiusServers: The RADIUS 802.1X servers to be used for authentication. This param is only valid if the authMode is 'open-with-radius', '8021x-radius' or 'ipsk-with-radius'
	radiusProxyEnabled: If true, Meraki devices will proxy RADIUS messages through the Meraki cloud to the configured RADIUS auth and accounting servers.
	radiusTestingEnabled: If true, Meraki devices will periodically send Access-Request messages to configured RADIUS servers using identity 'meraki_8021x_test' to ensure that the RADIUS servers are reachable.
	radiusCalledStationId: The template of the called station identifier to be used for RADIUS (ex. $NODE_MAC$:$VAP_NUM$).
	radiusAuthenticationNasId: The template of the NAS identifier to be used for RADIUS authentication (ex. $NODE_MAC$:$VAP_NUM$).
	radiusServerTimeout: The amount of time for which a RADIUS client waits for a reply from the RADIUS server (must be between 1-10 seconds).
	radiusServerAttemptsLimit: The maximum number of transmit attempts after which a RADIUS server is failed over (must be between 1-5).
	radiusFallbackEnabled: Whether or not higher priority RADIUS servers should be retried after 60 seconds.
	radiusCoaEnabled: If true, Meraki devices will act as a RADIUS Dynamic Authorization Server and will respond to RADIUS Change-of-Authorization and Disconnect messages sent by the RADIUS server.
	radiusFailoverPolicy: This policy determines how authentication requests should be handled in the event that all of the configured RADIUS servers are unreachable ('Deny access' or 'Allow access')
	radiusLoadBalancingPolicy: This policy determines which RADIUS server will be contacted first in an authentication attempt and the ordering of any necessary retry attempts ('Strict priority order' or 'Round robin')
	radiusAccountingEnabled: Whether or not RADIUS accounting is enabled. This param is only valid if the authMode is 'open-with-radius', '8021x-radius' or 'ipsk-with-radius'
	radiusAccountingServers: The RADIUS accounting 802.1X servers to be used for authentication. This param is only valid if the authMode is 'open-with-radius', '8021x-radius' or 'ipsk-with-radius' and radiusAccountingEnabled is 'true'
	radiusAccountingInterimInterval: The interval (in seconds) in which accounting information is updated and sent to the RADIUS accounting server.
	radiusAttributeForGroupPolicies: Specify the RADIUS attribute used to look up group policies ('Filter-Id', 'Reply-Message', 'Airespace-ACL-Name' or 'Aruba-User-Role'). Access points must receive this attribute in the RADIUS Access-Accept message
	ipAssignmentMode: The client IP assignment mode ('NAT mode', 'Bridge mode', 'Layer 3 roaming', 'Ethernet over GRE', 'Layer 3 roaming with a concentrator' or 'VPN')
	useVlanTagging: Whether or not traffic should be directed to use specific VLANs. This param is only valid if the ipAssignmentMode is 'Bridge mode' or 'Layer 3 roaming'
	concentratorNetworkId: The concentrator to use when the ipAssignmentMode is 'Layer 3 roaming with a concentrator' or 'VPN'.
	secondaryConcentratorNetworkId: The secondary concentrator to use when the ipAssignmentMode is 'VPN'. If configured, the APs will switch to using this concentrator if the primary concentrator is unreachable. This param is optional. ('disabled' represents no secondary concentrator.)
	disassociateClientsOnVpnFailover: Disassociate clients when 'VPN' concentrator failover occurs in order to trigger clients to re-associate and generate new DHCP requests. This param is only valid if ipAssignmentMode is 'VPN'.
	vlanId: The VLAN ID used for VLAN tagging. This param is only valid when the ipAssignmentMode is 'Layer 3 roaming with a concentrator' or 'VPN'
	defaultVlanId: The default VLAN ID used for 'all other APs'. This param is only valid when the ipAssignmentMode is 'Bridge mode' or 'Layer 3 roaming'
	apTagsAndVlanIds: The list of tags and VLAN IDs used for VLAN tagging. This param is only valid when the ipAssignmentMode is 'Bridge mode' or 'Layer 3 roaming'
	walledGardenEnabled: Allow access to a configurable list of IP ranges, which users may access prior to sign-on.
	walledGardenRanges: Specify your walled garden by entering an array of addresses, ranges using CIDR notation, domain names, and domain wildcards (e.g. '192.168.1.1/24', '192.168.37.10/32', 'www.yahoo.com', '*.google.com']). Meraki's splash page is automatically included in your walled garden.
	gre: Ethernet over GRE settings
	radiusOverride: If true, the RADIUS response can override VLAN tag. This is not valid when ipAssignmentMode is 'NAT mode'.
	radiusGuestVlanEnabled: Whether or not RADIUS Guest VLAN is enabled. This param is only valid if the authMode is 'open-with-radius' and addressing mode is not set to 'isolated' or 'nat' mode
	radiusGuestVlanId: VLAN ID of the RADIUS Guest VLAN. This param is only valid if the authMode is 'open-with-radius' and addressing mode is not set to 'isolated' or 'nat' mode
	minBitrate: The minimum bitrate in Mbps of this SSID in the default indoor RF profile. ('1', '2', '5.5', '6', '9', '11', '12', '18', '24', '36', '48' or '54')
	bandSelection: The client-serving radio frequencies of this SSID in the default indoor RF profile. ('Dual band operation', '5 GHz band only' or 'Dual band operation with Band Steering')
	perClientBandwidthLimitUp: The upload bandwidth limit in Kbps. (0 represents no limit.)
	perClientBandwidthLimitDown: The download bandwidth limit in Kbps. (0 represents no limit.)
	perSsidBandwidthLimitUp: The total upload bandwidth limit in Kbps. (0 represents no limit.)
	perSsidBandwidthLimitDown: The total download bandwidth limit in Kbps. (0 represents no limit.)
	lanIsolationEnabled: Boolean indicating whether Layer 2 LAN isolation should be enabled or disabled. Only configurable when ipAssignmentMode is 'Bridge mode'.
	visible: Boolean indicating whether APs should advertise or hide this SSID. APs will only broadcast this SSID if set to true
	availableOnAllAps: Boolean indicating whether all APs should broadcast the SSID or if it should be restricted to APs matching any availability tags. Can only be false if the SSID has availability tags.
	availabilityTags: Accepts a list of tags for this SSID. If availableOnAllAps is false, then the SSID will only be broadcast by APs with tags matching any of the tags in this list.
	mandatoryDhcpEnabled: If true, Mandatory DHCP will enforce that clients connecting to this SSID must use the IP address assigned by the DHCP server. Clients who use a static IP address won't be able to associate.
	adultContentFilteringEnabled: Boolean indicating whether or not adult content will be blocked
	dnsRewrite: DNS servers rewrite settings
	speedBurst: The SpeedBurst setting for this SSID'
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/ssids/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
