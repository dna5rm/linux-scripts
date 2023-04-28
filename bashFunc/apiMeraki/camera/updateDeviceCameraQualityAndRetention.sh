## updateDeviceCameraQualityAndRetention # Update quality and retention settings for the given camera
# https://developer.cisco.com/meraki/api-v1/#!update-device-camera-quality-and-retention

function updateDeviceCameraQualityAndRetention ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update quality and retention settings for the given camera
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-device-camera-quality-and-retention
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	profileId: The ID of a quality and retention profile to assign to the camera. The profile's settings will override all of the per-camera quality and retention settings. If the value of this parameter is null, any existing profile will be unassigned from the camera.
	motionBasedRetentionEnabled: Boolean indicating if motion-based retention is enabled(true) or disabled(false) on the camera.
	audioRecordingEnabled: Boolean indicating if audio recording is enabled(true) or disabled(false) on the camera
	restrictedBandwidthModeEnabled: Boolean indicating if restricted bandwidth is enabled(true) or disabled(false) on the camera. This setting does not apply to MV2 cameras.
	quality: Quality of the camera. Can be one of 'Standard', 'High' or 'Enhanced'. Not all qualities are supported by every camera model.
	resolution: Resolution of the camera. Can be one of '1280x720', '1920x1080', '1080x1080', '2058x2058', '2112x2112', '2880x2880', '2688x1512' or '3840x2160'.Not all resolutions are supported by every camera model.
	motionDetectorVersion: The version of the motion detector that will be used by the camera. Only applies to Gen 2 cameras. Defaults to v2.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/devices/${1}/camera/qualityAndRetention" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
