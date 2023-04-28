## updateNetworkSwitchQosRule # Update a quality of service rule
# https://developer.cisco.com/meraki/api-v1/#!update-network-switch-qos-rule

function updateNetworkSwitchQosRule ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a quality of service rule
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-switch-qos-rule
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	qosRuleId: \${2} (${2:-required})
	---
	vlan: The VLAN of the incoming packet. A null value will match any VLAN.
	protocol: The protocol of the incoming packet. Can be one of "ANY", "TCP" or "UDP". Default value is "ANY".
	srcPort: The source port of the incoming packet. Applicable only if protocol is TCP or UDP.
	srcPortRange: The source port range of the incoming packet. Applicable only if protocol is set to TCP or UDP. Example: 70-80
	dstPort: The destination port of the incoming packet. Applicable only if protocol is TCP or UDP.
	dstPortRange: The destination port range of the incoming packet. Applicable only if protocol is set to TCP or UDP. Example: 70-80
	dscp: DSCP tag that should be assigned to incoming packet. Set this to -1 to trust incoming DSCP. Default value is 0.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/switch/qosRules/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
