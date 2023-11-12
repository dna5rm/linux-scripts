# Get a vector representation of a given input that can be easily consumed by machine learning models and algorithms.

function openai_embeddings() {

    # Get the function source.
    local func_source="${FUNCNAME[0]}"

    # Use user_input var, args or stdin as input.
    [[ -z "${user_input}" ]] && {
        [[ -t 0 ]] && {
            local user_input="${@}"
        } || {
            local user_input=$(</dev/stdin)
        }
    }

    # Run tests and set func_error any fail.
    if ! type curl >/dev/null 2>&1; then
        local func_error="curl executable not found."
    elif ! type jq >/dev/null 2>&1; then
        local func_error="jq executable not found."
    elif [[ -z "${OPENAI_API_KEY}" ]]; then
        local func_error="\${OPENAI_API_KEY} is missing."
    elif [[ -z "${user_input}" ]]; then
        local func_error="\${user_input} is missing."
    fi

    # Return if any checks failed.
    [[ ! -z "${func_error}" ]] && {
        [[ "${0}" != "-bash" ]] && {
            echo >&2 "$(basename "${0}"):${func_source} - ${func_error}"
        } || {
            echo >&2 "${func_source} - ${func_error}"
        }
        return 1
    } || {
        # Build the openai_data json.
        local openai_data="$(jq --null-input --arg model "${OPENAI_MODEL:-text-embedding-ada-002}" \
          --arg input "${user_input}" \
          --arg encoding_format "${OPENAI_ENCODING:-float}" \
          --arg user "$(md5sum -t <(printf "%s:${func_source}" `whoami`) | awk '{print $1}')" '{
            "model": $model|tostring,
            "input": $input|tostring,
            "encoding_format": $encoding_format|tostring,
            "user": $user|tostring
          }')"
    }

    # Validate chat_data variable is good.
    jq -e '.' >/dev/null 2>&1 <<< "${openai_data:-ERR}" > /dev/null && {

        # Create a hash of the input for caching.
        local cache="${HOME}/.cache/$(basename "${func_source}")"
        local hash="$(awk '{$1=$1};1' <<< "${user_input[@],,}" | md5sum -t | awk '{print $1}')"

        # Check if there is a cached response and if it is older than 30 days.
        if [[ ! -f "${cache}/${hash}" ]] || [[ $(find "${cache}/${hash}" -mtime +30 -print) ]]; then

            # Fetch the response from OpenAI.
            local response=$(curl --silent --insecure --location --write-out "%{http_code}" \
              --request POST --url "https://api.openai.com/v1/embeddings" \
              --header "Content-Type: application/json" --header "Authorization: Bearer ${OPENAI_API_KEY}" \
              --data "${openai_data:-{\}}")

            # Handle the response or error code.
            local http_code=$(tail -n1 <<< "${response}")
            case "${http_code}" in
                200)
                    # Add prompt used to the response.
                   local response=`jq -c --arg input "${user_input}" --arg encoding_format "${OPENAI_ENCODING:-float}" \
                     '. += {"input": $input|tostring, "encoding_format": $encoding_format}' <(sed '$ d' <<< "${response}")`

                    # Cache the response (fresh).
                    install -m 644 -D <(jq -c '.' <<< "${response}") "${cache}/${hash}"
                    ;;
                *)
                    # Return the message.
                    echo "$(basename "${func_source}"): <${http_code}> $(jq -r '.error | "\(.type) - \(.message)"' \
                      <(sed '$ d' <<< "${response}"))"
                    return 1;;
            esac
        else
            # Get the cached response.
            local response="$(jq -c '.' "${cache}/${hash}")"
        fi

        # Return the response message content.
        jq -r '.data[].embedding' <<< "${response}" | sed '/./,$!d'

    } || {
        # Something went wrong.
        echo >&2 "${func_source} - \${openai_data} is not valid json."
        return 1
    }
}
