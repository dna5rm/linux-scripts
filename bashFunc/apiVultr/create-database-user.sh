## create-database-user # Create Database User
# /databases/{database-id}/users

function create-database-user ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${VULTR_API_URI}" ]] || [[ -z "${VULTR_API_KEY}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create a new database user within the Managed Database. Supply optional attributes as desired.
	Ref: /databases/{database-id}/users
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	202   Created
	400   Bad Request
	401   Unauthorized
	403   Forbidden
	404   Not Found
	422   Validation Error
	
	EOF
    else
        curl --silent --location --request POST --url "${VULTR_API_URI}/databases/${1}/users" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
