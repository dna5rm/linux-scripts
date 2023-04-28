## getNetworkInsightApplicationHealthByTime # Get application health by time
# https://developer.cisco.com/meraki/api-v1/#!get-network-insight-application-health-by-time

function getNetworkInsightApplicationHealthByTime ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get application health by time
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-insight-application-health-by-time
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	applicationId: \${2} (${2:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 7 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 7 days after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 7 days. The default is 2 hours.
	resolution: The time resolution in seconds for returned data. The valid resolutions are: 60, 300, 3600, 86400. The default is 300.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/insight/applications/${2}/healthByTime" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
