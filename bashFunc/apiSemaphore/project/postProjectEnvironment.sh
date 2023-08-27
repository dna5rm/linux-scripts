## postProjectEnvironment # Add environment
# /project/{project_id}/environment

function postProjectEnvironment ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${semaphore_api}" ]] || [[ ! -f "${HOME}/.cache/semaphore.cookie" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Add environment
	Ref: /project/{project_id}/environment
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication Cookie: postAuthLogin.sh ($(test -f "${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))
	
	[7mParameter Schema(B[m
	env:
	  example: '{}'
	  type: string
	json:
	  example: '{}'
	  type: string
	name:
	  example: Test
	  type: string
	password:
	  type: string
	project_id:
	  minimum: 1
	  type: integer
	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request POST --url "${semaphore_api}/project/${1}/environment" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/semaphore.cookie" --data "${2:-{\}}")
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
