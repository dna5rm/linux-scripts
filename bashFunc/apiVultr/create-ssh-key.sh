## create-ssh-key # Create SSH key
# /ssh-keys

function create-ssh-key ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create a new SSH Key for use with future instances. This does not update any running instances.
	Ref: /ssh-keys
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	201   Created
	400   Bad Request
	401   Unauthorized
	
	EOF
    else
        curl --silent --location --request POST --url "${VULTR_API_URI}/ssh-keys" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
