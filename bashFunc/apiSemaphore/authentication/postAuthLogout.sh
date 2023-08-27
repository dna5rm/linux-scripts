## postAuthLogout # Destroys current session
# /auth/logout

function postAuthLogout ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Destroys current session
	Ref: /auth/logout
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication Cookie: postAuthLogin.sh ($(test -f "${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))

	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request POST --url "${semaphore_api}/auth/logout" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/semaphore.cookie" --data "${1:-{\}}")
        http_code=$(tail -n1 <<< "${response}")

        # Return response or error description.
        case "${http_code}" in
            *)
                # return the content
                sed '$ d' <<< "${response}"
                ;;
        esac

        # Delete the stale session cookie.
        [[ -f "${HOME}/.cache/semaphore.cookie" ]] && { rm "${HOME}/.cache/semaphore.cookie"; }

    fi
}
