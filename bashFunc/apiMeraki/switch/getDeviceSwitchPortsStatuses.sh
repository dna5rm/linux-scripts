## getDeviceSwitchPortsStatuses # Return the status for all the ports of a switch
# https://developer.cisco.com/meraki/api-v1/#!get-device-switch-ports-statuses

function getDeviceSwitchPortsStatuses ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return the status for all the ports of a switch
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-device-switch-ports-statuses
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 31 days from today.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameter t0. The value must be in seconds and be less than or equal to 31 days. The default is 1 day.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/devices/${1}/switch/ports/statuses" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
