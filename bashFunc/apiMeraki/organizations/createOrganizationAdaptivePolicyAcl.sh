## createOrganizationAdaptivePolicyAcl # Creates new adaptive policy ACL
# https://developer.cisco.com/meraki/api-v1/#!create-organization-adaptive-policy-acl

function createOrganizationAdaptivePolicyAcl ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Creates new adaptive policy ACL
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-organization-adaptive-policy-acl
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	name: Name of the adaptive policy ACL
	rules: An ordered array of the adaptive policy ACL rules.
	ipVersion: IP version of adpative policy ACL. One of: 'any', 'ipv4' or 'ipv6'
	description: Description of the adaptive policy ACL
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/organizations/${1}/adaptivePolicy/acls" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
