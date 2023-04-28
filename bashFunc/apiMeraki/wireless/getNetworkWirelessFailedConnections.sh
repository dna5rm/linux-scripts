## getNetworkWirelessFailedConnections # List of all failed client connection events on this network in a given time range
# https://developer.cisco.com/meraki/api-v1/#!get-network-wireless-failed-connections

function getNetworkWirelessFailedConnections ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List of all failed client connection events on this network in a given time range
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-wireless-failed-connections
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 180 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 7 days after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 7 days.
	band: Filter results by band (either '2.4', '5' or '6'). Note that data prior to February 2020 will not have band information.
	ssid: Filter results by SSID
	vlan: Filter results by VLAN
	apTag: Filter results by AP Tag
	serial: Filter by AP
	clientId: Filter by client MAC
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/wireless/failedConnections" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
