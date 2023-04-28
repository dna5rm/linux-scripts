## claimIntoOrganizationInventory # Claim a list of devices, licenses, and/or orders into an organization inventory
# https://developer.cisco.com/meraki/api-v1/#!claim-into-organization-inventory

function claimIntoOrganizationInventory ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Claim a list of devices, licenses, and/or orders into an organization inventory
	Ref: https://developer.cisco.com/meraki/api-v1/#!claim-into-organization-inventory
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	orders: The numbers of the orders that should be claimed
	serials: The serials of the devices that should be claimed
	licenses: The licenses that should be claimed
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/organizations/${1}/inventory/claim" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
