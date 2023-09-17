## getVlans # null
# /api/ipam/vlans/{id}/

function getVlans ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${netbox_api}" ]] || [[ -z "${netbox_token}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - null
	Ref: /api/ipam/vlans/{id}/
	---
	API Base URI: \${netbox_api} (${netbox_api:-required})
	Authentication Token: \${netbox_token} (${netbox_token:-required})
	
	[3mParameter Schema[m
	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request GET --url "${netbox_api}/api/ipam/vlans/${1}" \
          --header "Content-Type: application/json" --header "Authorization: Token ${netbox_token}" \
          --data "${2:-{\}}")
        http_code=$(tail -n1 <<< "${response}")

        # Return response or error description.
        case "${http_code}" in

            *)
                # return the content
                sed '$ d' <<< "${response}"
                ;;
        esac

    fi
}
