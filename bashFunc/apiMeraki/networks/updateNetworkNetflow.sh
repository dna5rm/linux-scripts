## updateNetworkNetflow # Update the NetFlow traffic reporting settings for a network
# https://developer.cisco.com/meraki/api-v1/#!update-network-netflow

function updateNetworkNetflow ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the NetFlow traffic reporting settings for a network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-netflow
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	reportingEnabled: Boolean indicating whether NetFlow traffic reporting is enabled (true) or disabled (false).
	collectorIp: The IPv4 address of the NetFlow collector.
	collectorPort: The port that the NetFlow collector will be listening on.
	etaEnabled: Boolean indicating whether Encrypted Traffic Analytics is enabled (true) or disabled (false).
	etaDstPort: The port that the Encrypted Traffic Analytics collector will be listening on.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/netflow" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
