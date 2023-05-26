## create-snapshot # Create Snapshot
# /snapshots

function create-snapshot ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${VULTR_API_URI}" ]] || [[ -z "${VULTR_API_KEY}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create a new Snapshot for `instance_id`.
	Ref: /snapshots
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	201   Created
	400   Bad Request
	401   Unauthorized
	
	EOF
    else
        curl --silent --location --request POST --url "${VULTR_API_URI}/snapshots" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
