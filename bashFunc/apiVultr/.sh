##  # 
# /bare-metals/{baremetal-id}

function  ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${opendcim_uri}" ]] || [[ -z "${VULTR_API_KEY}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - 
	Ref: /bare-metals/{baremetal-id}
	---
	API Base URI: \${opendcim_uri} (${opendcim_uri:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	
	EOF
    else
        curl --silent --insecure --location --request PARAMETERS --url "${opendcim_uri}/bare-metals/${1}" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
