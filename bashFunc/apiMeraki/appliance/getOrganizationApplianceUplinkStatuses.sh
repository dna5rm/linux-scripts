## getOrganizationApplianceUplinkStatuses # List the uplink status of every Meraki MX and Z series appliances in the organization
# https://developer.cisco.com/meraki/api-v1/#!get-organization-appliance-uplink-statuses

function getOrganizationApplianceUplinkStatuses ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the uplink status of every Meraki MX and Z series appliances in the organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-appliance-uplink-statuses
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	total_pages: use with perPage to get total results up to total_pages*perPage; -1 or "all" for all pages
	direction: direction to paginate, either "next" (default) or "prev" page
	perPage: The number of entries per page returned. Acceptable range is 3 - 1000. Default is 1000.
	startingAfter: A token used by the server to indicate the start of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	endingBefore: A token used by the server to indicate the end of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	networkIds: A list of network IDs. The returned devices will be filtered to only include these networks.
	serials: A list of serial numbers. The returned devices will be filtered to only include these serials.
	iccids: A list of ICCIDs. The returned devices will be filtered to only include these ICCIDs.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/appliance/uplink/statuses" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
