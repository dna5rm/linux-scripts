## generateDeviceCameraSnapshot # Generate a snapshot of what the camera sees at the specified time and return a link to that image.
# https://developer.cisco.com/meraki/api-v1/#!generate-device-camera-snapshot

function generateDeviceCameraSnapshot ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Generate a snapshot of what the camera sees at the specified time and return a link to that image.
	Ref: https://developer.cisco.com/meraki/api-v1/#!generate-device-camera-snapshot
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	timestamp: [optional] The snapshot will be taken from this time on the camera. The timestamp is expected to be in ISO 8601 format. If no timestamp is specified, we will assume current time.
	fullframe: [optional] If set to "true" the snapshot will be taken at full sensor resolution. This will error if used with timestamp.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/devices/${1}/camera/generateSnapshot" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
