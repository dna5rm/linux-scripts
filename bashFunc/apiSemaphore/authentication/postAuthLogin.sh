## postAuthLogin # Performs Login
# /auth/login

function postAuthLogin ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${semaphore_api}" ]] || [[ -z "${semaphore_auth}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Performs Login
	Ref: /auth/login
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication: \${semaphore_auth} (${semaphore_auth:-required})

	EOF
    elif [[ ! -f "${HOME}/.cache/semaphore.cookie" ]]; then
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request POST --url "${semaphore_api}/auth/login" \
          --header "Content-Type: application/json" \
          --cookie-jar "${HOME}/.cache/semaphore.cookie" --data "${semaphore_auth:-{\}}")
        http_code=$(tail -n1 <<< "${response}")

        # Return response or error description.
        case "${http_code}" in
            400)
                echo "[400] something in body is missing / is invalid"
                ;;
            *)
                # return the content
                sed '$ d' <<< "${response}"
                ;;
        esac

    fi
}