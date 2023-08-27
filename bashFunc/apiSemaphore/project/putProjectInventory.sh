## putProjectInventory # Updates inventory
# /project/{project_id}/inventory/{inventory_id}

function putProjectInventory ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${semaphore_api}" ]] || [[ ! -f "${HOME}/.cache/semaphore.cookie" ]] || [[ -z "${2}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Updates inventory
	Ref: /project/{project_id}/inventory/{inventory_id}
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication Cookie: postAuthLogin.sh ($(test -f "${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))
	
	[7mParameter Schema(B[m
	become_key_id:
	  minimum: 1
	  type: integer
	inventory:
	  type: string
	name:
	  example: Test
	  type: string
	project_id:
	  minimum: 1
	  type: integer
	ssh_key_id:
	  minimum: 1
	  type: integer
	type:
	  enum:
	  - static
	  - static-yaml
	  - file
	  type: string
	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request PUT --url "${semaphore_api}/project/${1}/inventory/${2}" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/semaphore.cookie" --data "${3:-{\}}")
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
