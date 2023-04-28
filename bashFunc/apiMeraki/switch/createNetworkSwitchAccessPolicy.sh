## createNetworkSwitchAccessPolicy # Create an access policy for a switch network
# https://developer.cisco.com/meraki/api-v1/#!create-network-switch-access-policy

function createNetworkSwitchAccessPolicy ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create an access policy for a switch network
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-switch-access-policy
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	name: Name of the access policy
	radiusServers: List of RADIUS servers to require connecting devices to authenticate against before granting network access
	radiusTestingEnabled: If enabled, Meraki devices will periodically send access-request messages to these RADIUS servers
	radiusCoaSupportEnabled: Change of authentication for RADIUS re-authentication and disconnection
	radiusAccountingEnabled: Enable to send start, interim-update and stop messages to a configured RADIUS accounting server for tracking connected clients
	hostMode: Choose the Host Mode for the access policy.
	urlRedirectWalledGardenEnabled: Enable to restrict access for clients to a specific set of IP addresses or hostnames prior to authentication
	radius: Object for RADIUS Settings
	guestPortBouncing: If enabled, Meraki devices will periodically send access-request messages to these RADIUS servers
	radiusAccountingServers: List of RADIUS accounting servers to require connecting devices to authenticate against before granting network access
	radiusGroupAttribute: Acceptable values are `""` for None, or `"11"` for Group Policies ACL
	accessPolicyType: Access Type of the policy. Automatically 'Hybrid authentication' when hostMode is 'Multi-Domain'.
	increaseAccessSpeed: Enabling this option will make switches execute 802.1X and MAC-bypass authentication simultaneously so that clients authenticate faster. Only required when accessPolicyType is 'Hybrid Authentication.
	guestVlanId: ID for the guest VLAN allow unauthorized devices access to limited network resources
	dot1x: 802.1x Settings
	voiceVlanClients: CDP/LLDP capable voice clients will be able to use this VLAN. Automatically true when hostMode is 'Multi-Domain'.
	urlRedirectWalledGardenRanges: IP address ranges, in CIDR notation, to restrict access for clients to a specific set of IP addresses or hostnames prior to authentication
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/switch/accessPolicies" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
