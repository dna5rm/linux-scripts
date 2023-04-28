## getDeviceLossAndLatencyHistory # Get the uplink loss percentage and latency in milliseconds, and goodput in kilobits per second for a wired network device.
# https://developer.cisco.com/meraki/api-v1/#!get-device-loss-and-latency-history

function getDeviceLossAndLatencyHistory ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get the uplink loss percentage and latency in milliseconds, and goodput in kilobits per second for a wired network device.
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-device-loss-and-latency-history
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	ip: The destination IP used to obtain the requested stats. This is required.
	t0: The beginning of the timespan for the data. The maximum lookback period is 60 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 31 days after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 31 days. The default is 1 day.
	resolution: The time resolution in seconds for returned data. The valid resolutions are: 60, 600, 3600, 86400. The default is 60.
	uplink: The WAN uplink used to obtain the requested stats. Valid uplinks are wan1, wan2, cellular. The default is wan1.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/devices/${1}/lossAndLatencyHistory" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
