## createOrganizationInventoryOnboardingCloudMonitoringExportEvent # Imports event logs related to the onboarding app into elastisearch
# https://developer.cisco.com/meraki/api-v1/#!create-organization-inventory-onboarding-cloud-monitoring-export-event

function createOrganizationInventoryOnboardingCloudMonitoringExportEvent ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Imports event logs related to the onboarding app into elastisearch
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-organization-inventory-onboarding-cloud-monitoring-export-event
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	logEvent: The type of log event this is recording, e.g. download or opening a banner
	timestamp: A JavaScript UTC datetime stamp for when the even occurred
	targetOS: The name of the onboarding distro being downloaded
	request: Used to describe if this event was the result of a redirect. E.g. a query param if an info banner is being used
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/organizations/${1}/inventory/onboarding/cloudMonitoring/exportEvents" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
