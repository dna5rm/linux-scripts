## moveOrganizationLicensesSeats # Move SM seats to another organization
# https://developer.cisco.com/meraki/api-v1/#!move-organization-licenses-seats

function moveOrganizationLicensesSeats ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Move SM seats to another organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!move-organization-licenses-seats
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	destOrganizationId: The ID of the organization to move the SM seats to
	licenseId: The ID of the SM license to move the seats from
	seatCount: The number of seats to move to the new organization. Must be less than or equal to the total number of seats of the license
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/organizations/${1}/licenses/moveSeats" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
