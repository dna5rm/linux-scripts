## getNetworkApplianceUplinksUsageHistory # Get the sent and received bytes for each uplink of a network.
# https://developer.cisco.com/meraki/api-v1/#!get-network-appliance-uplinks-usage-history

function getNetworkApplianceUplinksUsageHistory ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get the sent and received bytes for each uplink of a network.
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-appliance-uplinks-usage-history
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 365 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 31 days after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 31 days. The default is 10 minutes.
	resolution: The time resolution in seconds for returned data. The valid resolutions are: 60, 300, 600, 1800, 3600, 86400. The default is 60.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/appliance/uplinks/usageHistory" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
