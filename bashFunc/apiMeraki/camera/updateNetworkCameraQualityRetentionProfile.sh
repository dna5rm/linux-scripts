## updateNetworkCameraQualityRetentionProfile # Update an existing quality retention profile for this network.
# https://developer.cisco.com/meraki/api-v1/#!update-network-camera-quality-retention-profile

function updateNetworkCameraQualityRetentionProfile ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${3}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update an existing quality retention profile for this network.
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-camera-quality-retention-profile
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	qualityRetentionProfileId: \${2} (${2:-required})
	---
	name: The name of the new profile. Must be unique.
	motionBasedRetentionEnabled: Deletes footage older than 3 days in which no motion was detected. Can be either true or false. Defaults to false. This setting does not apply to MV2 cameras.
	restrictedBandwidthModeEnabled: Disable features that require additional bandwidth such as Motion Recap. Can be either true or false. Defaults to false. This setting does not apply to MV2 cameras.
	audioRecordingEnabled: Whether or not to record audio. Can be either true or false. Defaults to false.
	cloudArchiveEnabled: Create redundant video backup using Cloud Archive. Can be either true or false. Defaults to false.
	motionDetectorVersion: The version of the motion detector that will be used by the camera. Only applies to Gen 2 cameras. Defaults to v2.
	scheduleId: Schedule for which this camera will record video, or 'null' to always record.
	maxRetentionDays: The maximum number of days for which the data will be stored, or 'null' to keep data until storage space runs out. If the former, it can be one of [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 14, 30, 60, 90] days.
	videoSettings: Video quality and resolution settings for all the camera models.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/camera/qualityRetentionProfiles/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
