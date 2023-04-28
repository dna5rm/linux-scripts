## createOrganizationInsightMonitoredMediaServer # Add a media server to be monitored for this organization
# https://developer.cisco.com/meraki/api-v1/#!create-organization-insight-monitored-media-server

function createOrganizationInsightMonitoredMediaServer ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Add a media server to be monitored for this organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-organization-insight-monitored-media-server
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	name: The name of the VoIP provider
	address: The IP address (IPv4 only) or hostname of the media server to monitor
	bestEffortMonitoringEnabled: Indicates that if the media server doesn't respond to ICMP pings, the nearest hop will be used in its stead.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/organizations/${1}/insight/monitoredMediaServers" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
