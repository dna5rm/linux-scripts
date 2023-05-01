# askAlpaca # Will query Alpaca LLM for brief response.
### Note ###
## Make sure Alpaca is compiled and executable from a system path.
## rename "chat" to "${PATH}/alpaca"

function askAlpaca()
{
    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Verify function requirements
    for req in aalpaca md5sum; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo >&2 "[${ERR}] ${FUNC_SOURCE} - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # Create a hash of arguments for caching.
    cachePath="${HOME}/.cache/$(basename "${FUNC_SOURCE}")"
    cacheHash="$(echo "${@,,}" | md5sum -t | awk '{print $1}')"

    [[ ! -z "${1}" ]] && {

        # Check if ${alpaca_model} is set.
        [[ ! -z "${alpaca_model}" ]] && {

            # Perform query & cache.
            [[ ! -f "${cachePath}/${cacheHash}" ]] && {
                install -m 644 -D  <(printf "[ $(date) ]\n\n${FUNCNAME[0]}:task: \"${1}\"\n\n") "${cachePath}/${cacheHash}"
                alpaca -m "${alpaca_model}" --color --temp 0.9 \
                 --prompt "Write a brief response that appropriately completes the request." \
                 --file <(echo "${1}") 2>> "${HOME}/${FUNCNAME[0]}.log" | tee -a "${cachePath}/${cacheHash}"
            } || {
                # Return the last query.
                awk 'END{print}' "${cachePath}/${cacheHash}"
            }

        } || {
            echo "${FUNCNAME[0]}: The variable \"\${alpaca_model}\" is not set..."
        }

    } || {
        printf "${FUNCNAME[0]}: Query the Alpaca LLM...\n\n"
        echo "Example>> ${FUNCNAME[0]} \"What is $(uname -s)?\""
    }
}
