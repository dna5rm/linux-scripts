## updateOrganizationAdaptivePolicyPolicy # Update an Adaptive Policy
# https://developer.cisco.com/meraki/api-v1/#!update-organization-adaptive-policy-policy

function updateOrganizationAdaptivePolicyPolicy ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update an Adaptive Policy
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-organization-adaptive-policy-policy
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	id: \${2} (${2:-required})
	---
	sourceGroup: The source adaptive policy group (requires one unique attribute)
	destinationGroup: The destination adaptive policy group (requires one unique attribute)
	acls: An ordered array of adaptive policy ACLs (each requires one unique attribute) that apply to this policy
	lastEntryRule: The rule to apply if there is no matching ACL
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/organizations/${1}/adaptivePolicy/policies/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
