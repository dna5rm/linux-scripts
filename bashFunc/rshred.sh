# Perform a recursive shred before deleting.

function rshred ()
{
    # Verify function requirements
    for req in shred; do
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
        [[ "${0}" != "-bash" ]] && {
            echo -n "$(basename "${0}"):"
        }
        echo "${FUNCNAME[0]} - Perform a recursive shred before deleting."
        echo "Input directory: \${1} (${1:-requried})

        Aborting..." | sed 's/^[ \t]*//g'
    else

        echo -n "shred: ${1} (y/n)? "
        read -n 1 reply
        echo

        if [[ "${reply,,}" == "y" ]]; then
            # Recursively shred all files in path.
            find "${1}" -type f -exec bash -c "shred --force --verbose --zero --iterations 3 {} && rm -rf {}" \;

            # Recursively delete path if directory.
            [[ -e "${1}" ]] && {
                find "${1}" -type d -empty -delete
            }
        fi

    fi

}
