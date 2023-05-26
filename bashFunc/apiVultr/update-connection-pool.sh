## update-connection-pool # Update Connection Pool
# /databases/{database-id}/connection-pools/{pool-name}

function update-connection-pool ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update connection-pool information within a Managed Database (PostgreSQL engine types only).
	Ref: /databases/{database-id}/connection-pools/{pool-name}
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	202   Accepted
	400   Bad Request
	401   Unauthorized
	404   Not Found
	422   Validation Error
	
	EOF
    else
        curl --silent --location --request PUT --url "${VULTR_API_URI}/databases/${1}/connection-pools/${2}" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${3:-{\}}"
    fi
}
