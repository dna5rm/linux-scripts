## deleteProjectTasks # Deletes task (including output)
# /project/{project_id}/tasks/{task_id}

function deleteProjectTasks ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Deletes task (including output)
	Ref: /project/{project_id}/tasks/{task_id}
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication Cookie: postAuthLogin.sh ($(test -f "${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))
	
	[7mParameter Schema(B[m
	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request DELETE --url "${semaphore_api}/project/${1}/tasks/${2}" \
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
