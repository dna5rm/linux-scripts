## updateNetworkSwitchRoutingOspf # Update layer 3 OSPF routing configuration
# https://developer.cisco.com/meraki/api-v1/#!update-network-switch-routing-ospf

function updateNetworkSwitchRoutingOspf ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update layer 3 OSPF routing configuration
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-switch-routing-ospf
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	enabled: Boolean value to enable or disable OSPF routing. OSPF routing is disabled by default.
	helloTimerInSeconds: Time interval in seconds at which hello packet will be sent to OSPF neighbors to maintain connectivity. Value must be between 1 and 255. Default is 10 seconds.
	deadTimerInSeconds: Time interval to determine when the peer will be declared inactive/dead. Value must be between 1 and 65535
	areas: OSPF areas
	v3: OSPF v3 configuration
	md5AuthenticationEnabled: Boolean value to enable or disable MD5 authentication. MD5 authentication is disabled by default.
	md5AuthenticationKey: MD5 authentication credentials. This param is only relevant if md5AuthenticationEnabled is true
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/switch/routing/ospf" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
