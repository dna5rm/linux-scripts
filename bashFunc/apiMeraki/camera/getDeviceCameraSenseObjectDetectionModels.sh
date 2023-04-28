## getDeviceCameraSenseObjectDetectionModels # Returns the MV Sense object detection model list for the given camera
# https://developer.cisco.com/meraki/api-v1/#!get-device-camera-sense-object-detection-models

function getDeviceCameraSenseObjectDetectionModels ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Returns the MV Sense object detection model list for the given camera
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-device-camera-sense-object-detection-models
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/devices/${1}/camera/sense/objectDetectionModels" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
