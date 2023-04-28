## getOrganizationApiRequests # List the API requests made by an organization
# https://developer.cisco.com/meraki/api-v1/#!get-organization-api-requests

function getOrganizationApiRequests ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the API requests made by an organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-api-requests
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	total_pages: use with perPage to get total results up to total_pages*perPage; -1 or "all" for all pages
	direction: direction to paginate, either "next" (default) or "prev" page
	t0: The beginning of the timespan for the data. The maximum lookback period is 31 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 31 days after t0.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 31 days. The default is 31 days.
	perPage: The number of entries per page returned. Acceptable range is 3 - 1000. Default is 50.
	startingAfter: A token used by the server to indicate the start of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	endingBefore: A token used by the server to indicate the end of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	adminId: Filter the results by the ID of the admin who made the API requests
	path: Filter the results by the path of the API requests
	method: Filter the results by the method of the API requests (must be 'GET', 'PUT', 'POST' or 'DELETE')
	responseCode: Filter the results by the response code of the API requests
	sourceIp: Filter the results by the IP address of the originating API request
	userAgent: Filter the results by the user agent string of the API request
	version: Filter the results by the API version of the API request
	operationIds: Filter the results by one or more operation IDs for the API request
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/apiRequests" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
