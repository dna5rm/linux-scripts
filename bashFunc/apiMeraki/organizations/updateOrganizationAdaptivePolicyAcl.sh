## updateOrganizationAdaptivePolicyAcl # Updates an adaptive policy ACL
# https://developer.cisco.com/meraki/api-v1/#!update-organization-adaptive-policy-acl

function updateOrganizationAdaptivePolicyAcl ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Updates an adaptive policy ACL
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-organization-adaptive-policy-acl
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	aclId: \${2} (${2:-required})
	---
	name: Name of the adaptive policy ACL
	description: Description of the adaptive policy ACL
	rules: An ordered array of the adaptive policy ACL rules. An empty array will clear the rules.
	ipVersion: IP version of adpative policy ACL. One of: 'any', 'ipv4' or 'ipv6'
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/organizations/${1}/adaptivePolicy/acls/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
