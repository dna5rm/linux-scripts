## getOrganizationAdaptivePolicyOverview # Returns adaptive policy aggregate statistics for an organization
# https://developer.cisco.com/meraki/api-v1/#!get-organization-adaptive-policy-overview

function getOrganizationAdaptivePolicyOverview ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Returns adaptive policy aggregate statistics for an organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-adaptive-policy-overview
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/adaptivePolicy/overview" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
