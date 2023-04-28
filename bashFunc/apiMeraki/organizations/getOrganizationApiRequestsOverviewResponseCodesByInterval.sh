## getOrganizationApiRequestsOverviewResponseCodesByInterval # Tracks organizations' API requests by response code across a given time period
# https://developer.cisco.com/meraki/api-v1/#!get-organization-api-requests-overview-response-codes-by-interval

function getOrganizationApiRequestsOverviewResponseCodesByInterval ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Tracks organizations' API requests by response code across a given time period
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-api-requests-overview-response-codes-by-interval
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 31 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 31 days after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 31 days. The default is 31 days. If interval is provided, the timespan will be autocalculated.
	interval: The time interval in seconds for returned data. The valid intervals are: 120, 3600, 14400, 21600. The default is 21600. Interval is calculated if time params are provided.
	version: Filter by API version of the endpoint. Allowable values are: [0, 1]
	operationIds: Filter by operation ID of the endpoint
	sourceIps: Filter by source IP that made the API request
	adminIds: Filter by admin ID of user that made the API request
	userAgent: Filter by user agent string for API request. This will filter by a complete or partial match.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/apiRequests/overview/responseCodes/byInterval" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
