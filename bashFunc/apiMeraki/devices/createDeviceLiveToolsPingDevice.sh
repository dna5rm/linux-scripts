## createDeviceLiveToolsPingDevice # Enqueue a job to check connectivity status to the device
# https://developer.cisco.com/meraki/api-v1/#!create-device-live-tools-ping-device

function createDeviceLiveToolsPingDevice ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Enqueue a job to check connectivity status to the device
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-device-live-tools-ping-device
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	count: Count parameter to pass to ping. [1..5], default 5
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/devices/${1}/liveTools/pingDevice" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
