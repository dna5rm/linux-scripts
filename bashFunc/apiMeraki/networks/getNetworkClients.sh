## getNetworkClients # List the clients that have used this network in the timespan
# https://developer.cisco.com/meraki/api-v1/#!get-network-clients

function getNetworkClients ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the clients that have used this network in the timespan
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-clients
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	total_pages: use with perPage to get total results up to total_pages*perPage; -1 or "all" for all pages
	direction: direction to paginate, either "next" (default) or "prev" page
	t0: The beginning of the timespan for the data. The maximum lookback period is 31 days from today.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameter t0. The value must be in seconds and be less than or equal to 31 days. The default is 1 day.
	perPage: The number of entries per page returned. Acceptable range is 3 - 1000. Default is 10.
	startingAfter: A token used by the server to indicate the start of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	endingBefore: A token used by the server to indicate the end of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	statuses: Filters clients based on status. Can be one of 'Online' or 'Offline'.
	ip: Filters clients based on a partial or full match for the ip address field.
	ip6: Filters clients based on a partial or full match for the ip6 address field.
	ip6Local: Filters clients based on a partial or full match for the ip6Local address field.
	mac: Filters clients based on a partial or full match for the mac address field.
	os: Filters clients based on a partial or full match for the os (operating system) field.
	description: Filters clients based on a partial or full match for the description field.
	vlan: Filters clients based on the full match for the VLAN field.
	recentDeviceConnections: Filters clients based on recent connection type. Can be one of 'Wired' or 'Wireless'.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/clients" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
