# askAlpaca # Will query Alpaca LLM for brief response.
### Note ###
## Make sure Alpaca is compiled and executable from a system path.
## rename "chat" to "${PATH}/alpaca"

# Ref: https://github.com/antimatter15/alpaca.cpp

function askAlpaca()
{
    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Verify function requirements
    for req in alpaca md5sum; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo >&2 "[${ERR}] ${FUNC_SOURCE} - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # Create a hash of arguments for caching.
    cachePath="${HOME}/.cache/$(basename "${FUNC_SOURCE}")"
    cacheHash="$(echo "${@,,}" | md5sum -t | awk '{print $1}')"

    if [[ -z "${alpaca_model}" ]] || [[ -z "${@}" ]]; then

        cat <<-EOF
	${FUNC_SOURCE} - Interface with Alpaca LLM

	Model: \${alpaca_model} (${alpaca_model:-required})
	Prompt: \${alpaca_prompt} (${alpaca_prompt:-optional})
	Query: \${@} (${@:-required})
	EOF

    else
        # Perform query & cache.
        [[ ! -f "${cachePath}/${cacheHash}" ]] && {
            install -m 644 -D  <(printf "[ $(date) ]\n\n${FUNCNAME[0]}:task: \"${1}\"\n\n") "${cachePath}/${cacheHash}"
            alpaca -m "${alpaca_model}" --color --temp 0.9 \
             --prompt "${alpaca_prompt:-Write a brief response that appropriately completes the request.}" \
             --file <(echo "${@}") 2>> "/dev/null" | tee -a "${cachePath}/${cacheHash}"
        } || {
            # Return the last query.
            sed '/^$/d' <(awk '/^$/{n++} n>1' "${cachePath}/${cacheHash}")
        }
    fi
}
