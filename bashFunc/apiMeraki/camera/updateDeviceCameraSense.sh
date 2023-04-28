## updateDeviceCameraSense # Update sense settings for the given camera
# https://developer.cisco.com/meraki/api-v1/#!update-device-camera-sense

function updateDeviceCameraSense ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update sense settings for the given camera
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-device-camera-sense
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	senseEnabled: Boolean indicating if sense(license) is enabled(true) or disabled(false) on the camera
	mqttBrokerId: The ID of the MQTT broker to be enabled on the camera. A value of null will disable MQTT on the camera
	audioDetection: The details of the audio detection config.
	detectionModelId: The ID of the object detection model
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/devices/${1}/camera/sense" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
