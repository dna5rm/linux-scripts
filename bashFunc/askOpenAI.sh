# askOpenAI # Will query the OpenAI API's for a completion of a provided prompt.
## https://platform.openai.com/docs/api-reference

function askOpenAI()
{
    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Verify function requirements
    for req in curl md5sum; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo >&2 "[${ERR}] ${FUNC_SOURCE} - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # Create a hash of arguments for caching.
    cachePath="${HOME}/.cache/$(basename "${FUNC_SOURCE}")"
    cacheHash="$(echo "${@,,}" | md5sum -t | awk '{print $1}')"

    if [[ -z "${OPENAI_API_KEY}" ]] || [[ -z "${1}" ]]; then
        cat <<-EOF
	${FUNC_SOURCE} - Creates a completion for the provided prompt.
	Ref: https://platform.openai.com/docs/api-reference/completions/create
	---
	apiKey: \${OPENAI_API_KEY} (${OPENAI_API_KEY:-required})
	model: \${OPENAI_MODEL} (${OPENAI_MODEL:-text-davinci-003})
	prompt: \${1} (${1:-required})
	temperature: \${OPENAI_TEMP} (${OPENAI_TEMP:-0.7})
	max_tokens: \${OPENAI_TOKENS} (${OPENAI_TOKENS:-1900})
	EOF
    else

        # Perform query & cache.
        [[ ! -f "${cachePath}/${cacheHash}" ]] && {
            jsonPost="{\"echo\": false}"
            jsonPost="$(jq --arg model "${OPENAI_MODEL:-text-davinci-003}" '. + {"model": $model}' <<<${jsonPost})"
            jsonPost="$(jq --arg prompt "${1:-Say this is a test!}" '. + {"prompt": $prompt}' <<<${jsonPost})"
            jsonPost="$(jq --arg temperature "${OPENAI_TEMP:-0.7}" '. + {"temperature": $temperature|tonumber}' <<<${jsonPost})"
            jsonPost="$(jq --arg max_tokens "${OPENAI_TOKENS:-1900}" '. + {"max_tokens": $max_tokens|tonumber}' <<<${jsonPost})"

            install -m 644 -D  <(printf "[ $(date) ]\n\n${FUNCNAME[0]}:task: \"${jsonPost}\"\n\n") "${cachePath}/${cacheHash}"

            curl --silent --location \
             --request POST --url "https://api.openai.com/v1/completions" \
             --header "Content-Type: application/json" \
             --header "Authorization: Bearer ${OPENAI_API_KEY}" \
             --data "${jsonPost}" | tee -a "${cachePath}/${cacheHash}"
        } || {
            # Return the last query.
            awk 'END{print}' "${cachePath}/${cacheHash}"
        }

    fi
}