# Return an OpenAI LLM completion response from provided input.

function openai_completions() {

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
        local func_error="\${OPENAI_API_KEY} is not configured."
    elif [[ -z "${user_input}" ]]; then
        local func_error="Missing User input."
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
        local openai_data="$(jq --null-input --arg model "${OPENAI_MODEL:-gpt-3.5-turbo-instruct}" \
          --arg prompt "${user_input}" \
          --arg temp "${OPENAI_TEMP:-0.7}" \
          --arg tokens "${OPENAI_TOKENS:-1900}" \
          --arg user "$(md5sum -t <(printf "%s:${func_source}" `whoami`) | awk '{print $1}')" '{
            "model": $model|tostring,
            "prompt": $prompt|tostring,
            "echo": false,
            "max_tokens": $tokens|tonumber,
            "temperature": $temp|tonumber,
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
              --request POST --url "https://api.openai.com/v1/completions" \
              --header "Content-Type: application/json" --header "Authorization: Bearer ${OPENAI_API_KEY}" \
              --data "${openai_data:-{\}}")

            # Handle the response or error code.
            local http_code=$(tail -n1 <<< "${response}")
            case "${http_code}" in
                200)
                    # Add prompt used to the response.
                    local response=`jq -c --arg prompt "${user_input}" --arg temp "${OPENAI_TEMP:-0.7}" \
                      '. += {"prompt": $prompt|tostring, "temperature": $temp|tonumber}' \
                      <(sed '$ d' <<< "${response}")`

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
        if type "${MARKDOWN:-glow}" >/dev/null 2>&1; then
            jq -r '. | "# " + .model, "", .choices[0].text' <<< "${response}" | "${MARKDOWN:-glow}"
        else
            # MARKDOWN cmd not found (raw output).
            jq -r '.choices[0].text' <<< "${resopnse}"
        fi
    } || {
        # Something went wrong.
        echo >&2 "${func_source} - \${openai_data} is not valid json."
        return 1
    }
}
