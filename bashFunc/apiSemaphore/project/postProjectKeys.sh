## postProjectKeys # Add access key
# /project/{project_id}/keys

function postProjectKeys ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Add access key
	Ref: /project/{project_id}/keys
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication Cookie: postAuthLogin.sh ($(test -f "${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))
	
	[7mParameter Schema(B[m
	name:
	  example: None
	  type: string
	  x-example: None
	project_id:
	  minimum: 1
	  type: integer
	  x-example: 2
	type:
	  enum:
	  - none
	  - ssh
	  - login_password
	  type: string
	  x-example: none
	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request POST --url "${semaphore_api}/project/${1}/keys" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/semaphore.cookie" --data "${2:-{\}}")
        http_code=$(tail -n1 <<< "${response}")

        # Return response or error description.
        case "${http_code}" in
            400)
                echo "[400] Bad type"
                ;;
            *)
                # return the content
                sed '$ d' <<< "${response}"
                ;;
        esac

    fi
}
