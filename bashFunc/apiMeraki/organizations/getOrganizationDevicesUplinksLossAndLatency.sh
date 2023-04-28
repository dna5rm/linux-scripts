## getOrganizationDevicesUplinksLossAndLatency # Return the uplink loss and latency for every MX in the organization from at latest 2 minutes ago
# https://developer.cisco.com/meraki/api-v1/#!get-organization-devices-uplinks-loss-and-latency

function getOrganizationDevicesUplinksLossAndLatency ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return the uplink loss and latency for every MX in the organization from at latest 2 minutes ago
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-devices-uplinks-loss-and-latency
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	t0: The beginning of the timespan for the data. The maximum lookback period is 60 days from today.
	t1: The end of the timespan for the data. t1 can be a maximum of 5 minutes after t0. The latest possible time that t1 can be is 2 minutes into the past.
	timespan: The timespan for which the information will be fetched. If specifying timespan, do not specify parameters t0 and t1. The value must be in seconds and be less than or equal to 5 minutes. The default is 5 minutes.
	uplink: Optional filter for a specific WAN uplink. Valid uplinks are wan1, wan2, cellular. Default will return all uplinks.
	ip: Optional filter for a specific destination IP. Default will return all destination IPs.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/devices/uplinksLossAndLatency" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
