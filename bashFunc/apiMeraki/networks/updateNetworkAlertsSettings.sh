## updateNetworkAlertsSettings # Update the alert configuration for this network
# https://developer.cisco.com/meraki/api-v1/#!update-network-alerts-settings

function updateNetworkAlertsSettings ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the alert configuration for this network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-alerts-settings
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	defaultDestinations: The network-wide destinations for all alerts on the network.
	alerts: Alert-specific configuration for each type. Only alerts that pertain to the network can be updated.
	EOF
    else
        curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/alerts/settings" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
