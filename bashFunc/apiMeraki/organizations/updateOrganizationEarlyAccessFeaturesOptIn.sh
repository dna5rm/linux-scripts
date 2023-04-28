## updateOrganizationEarlyAccessFeaturesOptIn # Update an early access feature opt-in for an organization
# https://developer.cisco.com/meraki/api-v1/#!update-organization-early-access-features-opt-in

function updateOrganizationEarlyAccessFeaturesOptIn ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update an early access feature opt-in for an organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-organization-early-access-features-opt-in
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	optInId: \${2} (${2:-required})
	---
	limitScopeToNetworks: A list of network IDs to apply the opt-in to
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/organizations/${1}/earlyAccess/features/optIns/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
