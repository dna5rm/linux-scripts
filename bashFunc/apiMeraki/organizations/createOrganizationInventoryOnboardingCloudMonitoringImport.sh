## createOrganizationInventoryOnboardingCloudMonitoringImport # Commits the import operation to complete the onboarding of a device into Dashboard for monitoring.
# https://developer.cisco.com/meraki/api-v1/#!create-organization-inventory-onboarding-cloud-monitoring-import

function createOrganizationInventoryOnboardingCloudMonitoringImport ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Commits the import operation to complete the onboarding of a device into Dashboard for monitoring.
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-organization-inventory-onboarding-cloud-monitoring-import
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	devices: A set of device imports to commit
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/organizations/${1}/inventory/onboarding/cloudMonitoring/imports" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
