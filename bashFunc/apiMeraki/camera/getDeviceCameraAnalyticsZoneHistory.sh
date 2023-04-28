## getDeviceCameraAnalyticsZoneHistory # Return historical records for analytic zones
# https://developer.cisco.com/meraki/api-v1/#!get-device-camera-analytics-zone-history

function getDeviceCameraAnalyticsZoneHistory ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return historical records for analytic zones
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-device-camera-analytics-zone-history
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	zoneId: \${2} (${2:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 365 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 14 hours after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 14 hours. The default is 1 hour.
	resolution: The time resolution in seconds for returned data. The valid resolutions are: 60. The default is 60.
	objectType: [optional] The object type for which analytics will be retrieved. The default object type is person. The available types are [person, vehicle].
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/devices/${1}/camera/analytics/zones/${2}/history" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
