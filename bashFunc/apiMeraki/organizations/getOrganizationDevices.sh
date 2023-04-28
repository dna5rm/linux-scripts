## getOrganizationDevices # List the devices in an organization
# https://developer.cisco.com/meraki/api-v1/#!get-organization-devices

function getOrganizationDevices ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the devices in an organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-devices
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
	configurationUpdatedAfter: Filter results by whether or not the device's configuration has been updated after the given timestamp
	networkIds: Optional parameter to filter devices by network.
	productTypes: Optional parameter to filter devices by product type. Valid types are wireless, appliance, switch, systemsManager, camera, cellularGateway, and sensor.
	tags: Optional parameter to filter devices by tags.
	tagsFilterType: Optional parameter of value 'withAnyTags' or 'withAllTags' to indicate whether to return networks which contain ANY or ALL of the included tags. If no type is included, 'withAnyTags' will be selected.
	name: Optional parameter to filter devices by name. All returned devices will have a name that contains the search term or is an exact match.
	mac: Optional parameter to filter devices by MAC address. All returned devices will have a MAC address that contains the search term or is an exact match.
	serial: Optional parameter to filter devices by serial number. All returned devices will have a serial number that contains the search term or is an exact match.
	model: Optional parameter to filter devices by model. All returned devices will have a model that contains the search term or is an exact match.
	macs: Optional parameter to filter devices by one or more MAC addresses. All returned devices will have a MAC address that is an exact match.
	serials: Optional parameter to filter devices by one or more serial numbers. All returned devices will have a serial number that is an exact match.
	sensorMetrics: Optional parameter to filter devices by the metrics that they provide. Only applies to sensor devices.
	sensorAlertProfileIds: Optional parameter to filter devices by the alert profiles that are bound to them. Only applies to sensor devices.
	models: Optional parameter to filter devices by one or more models. All returned devices will have a model that is an exact match.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/devices" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
