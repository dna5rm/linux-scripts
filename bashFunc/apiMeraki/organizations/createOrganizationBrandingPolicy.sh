## createOrganizationBrandingPolicy # Add a new branding policy to an organization
# https://developer.cisco.com/meraki/api-v1/#!create-organization-branding-policy

function createOrganizationBrandingPolicy ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Add a new branding policy to an organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-organization-branding-policy
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	name: Name of the Dashboard branding policy.
	enabled: Boolean indicating whether this policy is enabled.
	adminSettings: Settings for describing which kinds of admins this policy applies to.
	helpSettings:       Settings for describing the modifications to various Help page features. Each property in this object accepts one of
	customLogo: Properties describing the custom logo attached to the branding policy.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/organizations/${1}/brandingPolicies" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
