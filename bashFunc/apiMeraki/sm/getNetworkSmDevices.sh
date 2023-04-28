## getNetworkSmDevices # List the devices enrolled in an SM network with various specified fields and filters
# https://developer.cisco.com/meraki/api-v1/#!get-network-sm-devices

function getNetworkSmDevices ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the devices enrolled in an SM network with various specified fields and filters
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-sm-devices
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	total_pages: use with perPage to get total results up to total_pages*perPage; -1 or "all" for all pages
	direction: direction to paginate, either "next" (default) or "prev" page
	fields: Additional fields that will be displayed for each device.
	wifiMacs: Filter devices by wifi mac(s).
	serials: Filter devices by serial(s).
	ids: Filter devices by id(s).
	scope: Specify a scope (one of all, none, withAny, withAll, withoutAny, or withoutAll) and a set of tags.
	perPage: The number of entries per page returned. Acceptable range is 3 - 1000. Default is 1000.
	startingAfter: A token used by the server to indicate the start of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	endingBefore: A token used by the server to indicate the end of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/sm/devices" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
