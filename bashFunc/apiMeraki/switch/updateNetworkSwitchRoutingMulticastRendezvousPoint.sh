## updateNetworkSwitchRoutingMulticastRendezvousPoint # Update a multicast rendezvous point
# https://developer.cisco.com/meraki/api-v1/#!update-network-switch-routing-multicast-rendezvous-point

function updateNetworkSwitchRoutingMulticastRendezvousPoint ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a multicast rendezvous point
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-switch-routing-multicast-rendezvous-point
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	rendezvousPointId: \${2} (${2:-required})
	---
	interfaceIp: The IP address of the interface to use
	multicastGroup: 'Any', or the IP address of a multicast group
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/switch/routing/multicast/rendezvousPoints/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
