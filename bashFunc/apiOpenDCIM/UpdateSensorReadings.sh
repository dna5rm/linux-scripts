## UpdateSensorReadings # Update Sensor Reading for a specific device
# /sensorreadings/{SensorID}

function UpdateSensorReadings ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${opendcim_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update Sensor Reading for a specific device
	Ref: /sensorreadings/{SensorID}
	---
	API Base URI: \${opendcim_uri} (${opendcim_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[7mParamater       Input   Req.    Type     Description(B[m
	SensorID        path    true    string   keyValue of the DeviceID to be updated
	body            body    true    false    
	
	[7mCode  Description(B[m
	200   successful operation
	401   Access denied.
	
	EOF
    else
        curl --silent --insecure --location --request POST --url "${opendcim_uri}/sensorreadings/${1}" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
