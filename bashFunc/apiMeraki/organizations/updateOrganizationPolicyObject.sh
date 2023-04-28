## updateOrganizationPolicyObject # Updates a Policy Object.
# https://developer.cisco.com/meraki/api-v1/#!update-organization-policy-object

function updateOrganizationPolicyObject ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Updates a Policy Object.
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-organization-policy-object
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	policyObjectId: \${2} (${2:-required})
	---
	name: Name of a policy object, unique within the organization (alphanumeric, space, dash, or underscore characters only)
	cidr: CIDR Value of a policy object (e.g. 10.11.12.1/24")
	fqdn: Fully qualified domain name of policy object (e.g. "example.com")
	mask: Mask of a policy object (e.g. "255.255.0.0")
	ip: IP Address of a policy object (e.g. "1.2.3.4")
	groupIds: The IDs of policy object groups the policy object belongs to
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/organizations/${1}/policyObjects/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
