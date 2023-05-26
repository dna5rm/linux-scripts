## update-dns-domain-record # Update Record
# /domains/{dns-domain}/records/{record-id}

function update-dns-domain-record ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the information for a DNS record. All attributes are optional. If not set, the attributes will retain their original values.
	Ref: /domains/{dns-domain}/records/{record-id}
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	204   No Content
	
	EOF
    else
        curl --silent --location --request PATCH --url "${VULTR_API_URI}/domains/${1}/records/${2}" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${3:-{\}}"
    fi
}
