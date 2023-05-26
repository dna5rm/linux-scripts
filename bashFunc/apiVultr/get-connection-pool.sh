## get-connection-pool # Get Connection Pool
# /databases/{database-id}/connection-pools/{pool-name}

function get-connection-pool ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${VULTR_API_URI}" ]] || [[ -z "${VULTR_API_KEY}" ]] || [[ -z "${2}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get information about a Managed Database connection pool (PostgreSQL engine types only).
	Ref: /databases/{database-id}/connection-pools/{pool-name}
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	200   OK
	400   Bad Request
	401   Unauthorized
	403   Forbidden
	404   Not Found
	
	EOF
    else
        curl --silent --location --request GET --url "${VULTR_API_URI}/databases/${1}/connection-pools/${2}" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${3:-{\}}"
    fi
}
