## get-bare-metal-vnc # Get VNC URL for a Bare Metal
# /bare-metals/{baremetal-id}/vnc

function get-bare-metal-vnc ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get the VNC URL for a Bare Metal
	Ref: /bare-metals/{baremetal-id}/vnc
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
        curl --silent --location --request GET --url "${VULTR_API_URI}/bare-metals/${1}/vnc" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
