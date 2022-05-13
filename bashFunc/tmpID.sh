# Set/Update a variable called ${tmpID} so users can share ssh identity files.

function tmpID ()
{
    # Verify function requirements
    for req in curl; do
        type ${req} >/dev/null 2>&1 || {
            # Skip basename if shell function
            [[ "${0}" != "-bash" ]] && {
                echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            } || {
                echo >&2 "${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
           }
            return 1
        }
    done

    # Print reference if conditions missing
    if [[ ${?} -eq 0 ]] && [[ -z "${1}" ]]; then
        # Skip basename if shell function
        [[ "${?}" -ne 0 ]] && {
            echo -n "$(basename "${0}"):"
        }
        echo "${FUNCNAME[0]} - Return or update \${tmpID} variable"
        echo "identity_file: \${1} (${1:-requried})

        Aborting..." | sed 's/^[ \t]*//g'
    elif [[ ${?} -eq 0 ]]; then
        if grep -q "PRIVATE KEY" "${1}"; then

            [[ -z "${tmpID}" ]] && {
                # Always clean up after exit
                trap 'rm -rf "${tmpID}"' SIGINT SIGTERM ERR EXIT
                tmpID="$(mktemp)"
            }

            # Copy ${1} to ${tmpID}
            chmod 600 "${tmpID}" && cat "${1}" > "${tmpID}"
        fi
    fi
}

