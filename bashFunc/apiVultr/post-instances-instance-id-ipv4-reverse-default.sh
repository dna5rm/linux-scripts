## post-instances-instance-id-ipv4-reverse-default # Set Default Reverse DNS Entry
# /instances/{instance-id}/ipv4/reverse/default

function post-instances-instance-id-ipv4-reverse-default ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Set a reverse DNS entry for an IPv4 address
	Ref: /instances/{instance-id}/ipv4/reverse/default
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	204   No Content
	400   Bad Request
	401   Unauthorized
	404   Not Found
	
	EOF
    else
        curl --silent --location --request POST --url "${VULTR_API_URI}/instances/${1}/ipv4/reverse/default" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
