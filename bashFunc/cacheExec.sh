## Cache a functions output
# Both display and cache API output for performance increase.

function cacheExec ()
{
    # Verify requirements
    for req in boxText find md5sum; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            return 1
        }
    done

    # Create directory to cache output for this function.
    cache_dir="${HOME}/.cache/$(basename "${0}")"
    [[ ! -d "${cache_dir}" ]] && {
        mkdir -p -m 700 "${cache_dir}"
    }

    # Create a hash of arguments
    execHash="$(echo "${@}" | md5sum -t | awk '{print $1}')"

    # Error if no function input!
    if [[ -z "${1}" ]]; then
        boxText "$(basename "${0}"):${FUNCNAME[0]} - No function name \${1}"

    # Display cache if less than 15min old.
    elif [[ -f "${cache_dir}/${FUNCNAME[0]}_${execHash}" ]] &&  [[ ! `find "${cache_dir}/${FUNCNAME[0]}_${execHash}" -mmin +15` ]]; then
        cat "${cache_dir}/${FUNCNAME[0]}_${execHash}"

    # Run function and cache the output.
    else
        (${@}) | tee "${cache_dir}/${FUNCNAME[0]}_${execHash}"
    fi
}
