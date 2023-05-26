## Cache a functions output
# Both display and cache API output for performance increase.

function cacheExec ()
{
    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Verify function requirements
    for req in find md5sum; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo >&2 "[${ERR}] ${FUNC_SOURCE} - \"${req}\" is not installed or found. Aborting." | sed 's/^\///'
            exit ${ERR}
        }
    done

    # Create a hash of arguments for caching.
    cachePath="${HOME}/.cache/$(basename "${0}" 2> /dev/null)"
    cacheHash="$(echo "${@,,}" | md5sum -t | awk '{print $1}')"

    # Error if no function input!
    if [[ -z "${@}" ]]; then
        echo "${FUNC_SOURCE} - No input: \${@}" | sed 's/^\///'

    # Display cache if less than 15min old.
    elif [[ -f "${cachePath}/${cacheHash}" ]] &&  [[ ! `find "${cachePath}/${cacheHash}" -mmin +15` ]]; then
        cat "${cachePath}/${cacheHash}"

    # Execute function input and cache stdout.
    else
        install -m 644 -D  <( (${@}) ) "${cachePath}/${cacheHash}" && cat "${cachePath}/${cacheHash}"
    fi
}
