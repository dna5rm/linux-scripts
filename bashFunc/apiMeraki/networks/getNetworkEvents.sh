## getNetworkEvents # List the events for the network
# https://developer.cisco.com/meraki/api-v1/#!get-network-events

function getNetworkEvents ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the events for the network
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-events
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	total_pages: use with perPage to get total results up to total_pages*perPage; -1 or "all" for all pages
	direction: direction to paginate, either "next" or "prev" (default) page
	event_log_end_time: ISO8601 Zulu/UTC time, to use in conjunction with startingAfter, to retrieve events within a time window
	productType: The product type to fetch events for. This parameter is required for networks with multiple device types. Valid types are wireless, appliance, switch, systemsManager, camera, and cellularGateway
	includedEventTypes: A list of event types. The returned events will be filtered to only include events with these types.
	excludedEventTypes: A list of event types. The returned events will be filtered to exclude events with these types.
	deviceMac: The MAC address of the Meraki device which the list of events will be filtered with
	deviceSerial: The serial of the Meraki device which the list of events will be filtered with
	deviceName: The name of the Meraki device which the list of events will be filtered with
	clientIp: The IP of the client which the list of events will be filtered with. Only supported for track-by-IP networks.
	clientMac: The MAC address of the client which the list of events will be filtered with. Only supported for track-by-MAC networks.
	clientName: The name, or partial name, of the client which the list of events will be filtered with
	smDeviceMac: The MAC address of the Systems Manager device which the list of events will be filtered with
	smDeviceName: The name of the Systems Manager device which the list of events will be filtered with
	perPage: The number of entries per page returned. Acceptable range is 3 - 1000. Default is 10.
	startingAfter: A token used by the server to indicate the start of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	endingBefore: A token used by the server to indicate the end of the page. Often this is a timestamp or an ID but it is not limited to those. This parameter should not be defined by client applications. The link for the first, last, prev, or next page in the HTTP Link header should define it.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/events" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
