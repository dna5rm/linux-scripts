## updateNetworkGroupPolicy # Update a group policy
# https://developer.cisco.com/meraki/api-v1/#!update-network-group-policy

function updateNetworkGroupPolicy ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a group policy
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-group-policy
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	groupPolicyId: \${2} (${2:-required})
	---
	name: The name for your group policy.
	scheduling:     The schedule for the group policy. Schedules are applied to days of the week.
	bandwidth:     The bandwidth settings for clients bound to your group policy.
	firewallAndTrafficShaping:     The firewall and traffic shaping rules and settings for your policy.
	contentFiltering: The content filtering settings for your group policy
	splashAuthSettings: Whether clients bound to your policy will bypass splash authorization or behave according to the network's rules. Can be one of 'network default' or 'bypass'. Only available if your network has a wireless configuration.
	vlanTagging: The VLAN tagging settings for your group policy. Only available if your network has a wireless configuration.
	bonjourForwarding: The Bonjour settings for your group policy. Only valid if your network has a wireless configuration.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/groupPolicies/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
