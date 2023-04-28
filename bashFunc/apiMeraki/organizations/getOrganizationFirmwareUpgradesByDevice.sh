## getOrganizationFirmwareUpgradesByDevice # Get firmware upgrade status for the filtered devices
# https://developer.cisco.com/meraki/api-v1/#!get-organization-firmware-upgrades-by-device

function getOrganizationFirmwareUpgradesByDevice ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get firmware upgrade status for the filtered devices
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-firmware-upgrades-by-device
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	total_pages: use with perPage to get total results up to total_pages*perPage; -1 or "all" for all pages
	direction: direction to paginate, either "next" (default) or "prev" page
	perPage: The number of entries per page returned. Acceptable range is 3 - 50. Default is 50.
	startingAfter: A token used by the server to indicate the start of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	endingBefore: A token used by the server to indicate the end of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	networkIds: Optional parameter to filter by network
	serials: Optional parameter to filter by serial number.  All returned devices will have a serial number that is an exact match.
	macs: Optional parameter to filter by one or more MAC addresses belonging to devices. All devices returned belong to MAC addresses that are an exact match.
	firmwareUpgradeIds: Optional parameter to filter by firmware upgrade ids.
	firmwareUpgradeBatchIds: Optional parameter to filter by firmware upgrade batch ids.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/firmware/upgrades/byDevice" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
