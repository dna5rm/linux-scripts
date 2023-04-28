## getDeviceCameraAnalyticsRecent # Returns most recent record for analytics zones
# https://developer.cisco.com/meraki/api-v1/#!get-device-camera-analytics-recent

function getDeviceCameraAnalyticsRecent ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Returns most recent record for analytics zones
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-device-camera-analytics-recent
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	objectType: [optional] The object type for which analytics will be retrieved. The default object type is person. The available types are [person, vehicle].
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/devices/${1}/camera/analytics/recent" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
