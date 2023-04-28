## updateOrganizationAlertsProfile # Update an organization-wide alert config
# https://developer.cisco.com/meraki/api-v1/#!update-organization-alerts-profile

function updateOrganizationAlertsProfile ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${3}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update an organization-wide alert config
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-organization-alerts-profile
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	alertConfigId: \${2} (${2:-required})
	---
	enabled: Is the alert config enabled
	type: The alert type
	alertCondition: The conditions that determine if the alert triggers
	recipients: List of recipients that will recieve the alert.
	networkTags: Networks with these tags will be monitored for the alert
	description: User supplied description of the alert
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/organizations/${1}/alerts/profiles/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
