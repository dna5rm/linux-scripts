## getNetworkWirelessDataRateHistory # Return PHY data rates over time for a network, device, or network client
# https://developer.cisco.com/meraki/api-v1/#!get-network-wireless-data-rate-history

function getNetworkWirelessDataRateHistory ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return PHY data rates over time for a network, device, or network client
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-wireless-data-rate-history
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 31 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 31 days after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 31 days. The default is 7 days.
	resolution: The time resolution in seconds for returned data. The valid resolutions are: 300, 600, 1200, 3600, 14400, 86400. The default is 86400.
	autoResolution: Automatically select a data resolution based on the given timespan; this overrides the value specified by the 'resolution' parameter. The default setting is false.
	clientId: Filter results by network client.
	deviceSerial: Filter results by device.
	apTag: Filter results by AP tag.
	band: Filter results by band (either '2.4', '5' or '6').
	ssid: Filter results by SSID number.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/wireless/dataRateHistory" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
