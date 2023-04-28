## getDeviceCameraAnalyticsOverview # Returns an overview of aggregate analytics data for a timespan
# https://developer.cisco.com/meraki/api-v1/#!get-device-camera-analytics-overview

function getDeviceCameraAnalyticsOverview ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Returns an overview of aggregate analytics data for a timespan
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-device-camera-analytics-overview
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 365 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 7 days after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 7 days. The default is 1 hour.
	objectType: [optional] The object type for which analytics will be retrieved. The default object type is person. The available types are [person, vehicle].
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/devices/${1}/camera/analytics/overview" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
