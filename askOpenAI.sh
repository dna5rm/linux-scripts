#!/bin/bash
## Use the askOpenAI bash function. *deprecated*

# Verify script requirements
for req in ansible-vault curl glow jq yq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Read credentials from vault.
[[ -f "${HOME}/.loginrc.vault" && "${HOME}/.vaultpw" ]] && {
    OPENAI_API_KEY=`yq -r '.OPENAI_API_KEY' <(ansible-vault view "${HOME}/.loginrc.vault" --vault-password-file "${HOME}/.vaultpw")`
} || {
    echo "$(basename "${0}"): Unable to get creds from vault."
    exit 1;
}

function askOpenAI() {
    # askOpenAI # Will query the OpenAI API's to complete a given task.
    ## https://platform.openai.com/docs/api-reference

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

    if [[ -z "${OPENAI_API_KEY}" ]] || [[ -z "${@}" ]]; then
        cat <<-EOF | sed 's/^[ \t]*//' | glow
        ## ${FUNC_SOURCE} - Interface with the OpenAI API.
        > apiKey: \${OPENAI_API_KEY} (${OPENAI_API_KEY:-required})
        > prompt: \${@} (${@:-required})
        ### Creates a completion for the provided prompt and parameters.
        - https://platform.openai.com/docs/api-reference/completions/create
        > model: \${OPENAI_MODEL} (${OPENAI_MODEL:-gpt-3.5-turbo-instruct})
        > temperature: \${OPENAI_TEMP} (${OPENAI_TEMP:-0.7})
        > max_tokens: \${OPENAI_TOKENS} (${OPENAI_TOKENS:-1900})
        ### Creates an image given a prompt.
        - https://platform.openai.com/docs/api-reference/images/create
        > task: \${@} ("image" + ${@:-required})
	EOF

    ## Creates an image given a prompt. ##
    elif [[ "${1,,}" == "image"* ]]; then
        # Perform query & cache.
        [[ ! -f "${cachePath}/${cacheHash}" ]] && {
            prompt="$(echo "${@}" | sed 's/^[^ ]* *//')"
            [[ "$(grep -E "\b(256x256|512x512|1024x1024)\b" <<<${1#*:})" ]] && { size="${1#*:}"; }

            jsonPost="{\"n\": 1, \"response_format\": \"b64_json\"}"
            jsonPost="$(jq --arg size "${size:-256x256}" '. + {"size": $size}' <<<${jsonPost})"
            jsonPost="$(jq --arg prompt "${prompt}" '. + {"prompt": $prompt}' <<<${jsonPost})"

            install -m 644 -D <(printf "[ $(date) ]\n\n${FUNCNAME[0]}:task: \"${jsonPost}\"\n\n") "${cachePath}/${cacheHash}"

            curl --silent --location \
             --request POST --url "https://api.openai.com/v1/images/generations" \
             --header "Content-Type: application/json" \
             --header "Authorization: Bearer ${OPENAI_API_KEY}" \
             --data "${jsonPost}" | jq -c '.' | tee -a "${cachePath}/${cacheHash}"
        } || {
            # Return the last query.
            awk 'END{print}' "${cachePath}/${cacheHash}"
        }

    ## Creates a completion for the provided prompt and parameters. ##
    else
        # Perform query & cache.
        [[ ! -f "${cachePath}/${cacheHash}" ]] && {
            prompt="${@}"
            jsonPost="{\"echo\": false}"
            jsonPost="$(jq --arg model "${OPENAI_MODEL:-gpt-3.5-turbo-instruct}" '. + {"model": $model}' <<<${jsonPost})"
            jsonPost="$(jq --arg prompt "${prompt}" '. + {"prompt": $prompt}' <<<${jsonPost})"
            jsonPost="$(jq --arg temperature "${OPENAI_TEMP:-0.7}" '. + {"temperature": $temperature|tonumber}' <<<${jsonPost})"
            jsonPost="$(jq --arg max_tokens "${OPENAI_TOKENS:-1900}" '. + {"max_tokens": $max_tokens|tonumber}' <<<${jsonPost})"

            install -m 644 -D <(printf "[ $(date) ]\n\n${FUNCNAME[0]}:task: \"${jsonPost}\"\n\n") "${cachePath}/${cacheHash}"

            curl --silent --location \
             --request POST --url "https://api.openai.com/v1/completions" \
             --header "Content-Type: application/json" \
             --header "Authorization: Bearer ${OPENAI_API_KEY}" \
             --data "${jsonPost}" | jq -c '.' | tee -a "${cachePath}/${cacheHash}"
        } || {
            # Return the last query.
            awk 'END{print}' "${cachePath}/${cacheHash}"
        }
    fi
}

if [[ -z "${@}" ]]; then
    askOpenAI
elif [[ "${1,,}" == "image"* ]]; then
    outputUUID="${HOME}/public_html/img/$(uuid).png"
    install -m 644 -D <(askOpenAI "${@}" | jq -r '.data[0].b64_json' | base64 -d) "${outputUUID}"
    [[ -f "${outputUUID}" ]] && { file "${outputUUID}"; }
else
    askOpenAI "${@}" | jq -r '. | "# "+ .model, "", .choices[0].text' | glow
fi
