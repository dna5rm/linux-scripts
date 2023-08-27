## putProjectSchedules # Updates schedule
# /project/{project_id}/schedules/{schedule_id}

function putProjectSchedules ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Updates schedule
	Ref: /project/{project_id}/schedules/{schedule_id}
	---
	API Base URI: \${semaphore_api} (${semaphore_api:-required})
	Authentication Cookie: postAuthLogin.sh ($(test -f "${HOME}/.cache/semaphore.cookie" && echo "present" || echo "missing"))
	
	[7mParameter Schema(B[m
	cron_format:
	  example: '* * * 1 *'
	  type: string
	  x-example: '* * * 1 *'
	id:
	  type: integer
	project_id:
	  type: integer
	template_id:
	  type: integer
	EOF
    else
        response=$(curl --silent --insecure --location --write-out "%{http_code}" \
          --request PUT --url "${semaphore_api}/project/${1}/schedules/${2}" \
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
