## postUsers # Creates a user
# /users

function postUsers ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Creates a user
	Ref: /users
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication Cookie: postAuthLogin.sh ($(test -f "${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))
	
	[7mParameter Schema(B[m
	admin:
	  type: boolean
	alert:
	  type: boolean
	email:
	  example: test@ansiblesemaphore.test
	  type: string
	  x-example: test@ansiblesemaphore.test
	name:
	  example: Integration Test User
	  type: string
	  x-example: Integration Test User
	username:
	  example: test-user
	  type: string
	  x-example: test-user
	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request POST --url "${semaphore_api}/users" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/semaphore.cookie" --data "${1:-{\}}")
        http_code=$(tail -n1 <<< "${response}")

        # Return response or error description.
        case "${http_code}" in
            400)
                echo "[400] User creation failed"
                ;;
            *)
                # return the content
                sed '$ d' <<< "${response}"
                ;;
        esac

    fi
}
