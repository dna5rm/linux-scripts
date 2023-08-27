## putUsers # Updates user details
# /users/{user_id}/

function putUsers ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Updates user details
	Ref: /users/{user_id}/
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication Cookie: postAuthLogin.sh ($(test -f "${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))
	
	[7mParameter Schema(B[m
	admin:
	  type: boolean
	alert:
	  type: boolean
	email:
	  example: test2@ansiblesemaphore.test
	  type: string
	  x-example: test2@ansiblesemaphore.test
	name:
	  example: Integration Test User2
	  type: string
	  x-example: Integration Test User2
	username:
	  example: test-user2
	  type: string
	  x-example: test-user2
	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request PUT --url "${semaphore_api}/users/${1}" \
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
