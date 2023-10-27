# Return a model response from OpenAI chat.
## https://platform.openai.com/docs/api-reference/chat

function openai_chat() {

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
    elif ! type tput >/dev/null 2>&1; then
        local func_error="tput executable not found."
    elif [[ -z "${OPENAI_API_KEY}" ]]; then
        local func_error="\${OPENAI_API_KEY} is not configured."
    fi

    # Return if any checks failed.
    if [[ ! -z "${func_error}" ]]; then
        [[ "${0}" != "-bash" ]] && {
            echo >&2 "$(basename "${0}"):${func_source} - ${func_error}"
        } || {
            echo >&2 "${func_source} - ${func_error}"
        }
        return 1
    elif [[ -z "${OPENAI_CHAT}" ]]; then
        # Build the OPENAI_CHAT json (not local var).
        OPENAI_CHAT="$(jq -cn --arg model "${OPENAI_MODEL:-gpt-3.5-turbo}" \
          --arg prompt "${OPENAI_PROMPT:-You are a helpful assistant.}" \
          --arg temp "${OPENAI_TEMP:-0.7}" \
          --arg tokens "${OPENAI_TOKENS:-1900}" \
          --arg user "$(md5sum -t <(printf "%s:${func_source}" `whoami`) | awk '{print $1}')" '{
            "model": $model|tostring,
            "messages": [
              {
                "role": "system",
                "content": $prompt|tostring
              }
            ],
            "temperature": $temp|tonumber,
            "max_tokens": $tokens|tonumber,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0,
            "user": $user|tostring
          }')"
    fi

    # Validate OPENAI_CHAT variable is good.
    jq -e '.' >/dev/null 2>&1 <<< "${OPENAI_CHAT:-ERR}" > /dev/null && {

        # Read user input if no variable.
        [[ -z "${user_input}" ]] && {
            tput setaf 2 && while IFS= read -r input; do
                case "${input}" in
                    $'\004') break ;; # CTRL+D
                    'debug') jq '.' <<< "${OPENAI_CHAT}" && tput setaf 2 ;;
                    *) user_input+=("$input") ;;
                esac
            done && tput sgr0
        }

        # Append user_input to OPENAI_CHAT variable.
        [[ ! -z "${user_input[@]}" ]] && {
            # Create a hash of the input for caching.
            local cache="${HOME}/.cache/$(basename "${func_source}")"
            local hash="$(awk '{$1=$1};1' <<< "${user_input[@],,}" | md5sum -t | awk '{print $1}')"
            OPENAI_CHAT=`jq -c --arg input "$(echo -e "${user_input[@]}")" \
              '.messages += [{"role": "user", "content": $input}]' <<< "${OPENAI_CHAT}"`
            unset user_input
        } || { return 0; }

        # Check if there is a cached response and if it is older than 30 days.
        if [[ ! -f "${cache}/${hash}" ]] || [[ $(find "${cache}/${hash}" -mtime +30 -print) ]]; then

            # Fetch the response from OpenAI.
            local response=$(curl --silent --insecure --location --write-out "%{http_code}" \
              --request POST --url "https://api.openai.com/v1/chat/completions" \
              --header "Content-Type: application/json" --header "Authorization: Bearer ${OPENAI_API_KEY}" \
              --data "${OPENAI_CHAT:-{\}}")

            # Handle the response or error code.
            local http_code=$(tail -n1 <<< "${response}")
            case "${http_code}" in
                200)
                    # Return the content (fresh).
                    OPENAI_CHAT=`jq -c --argjson message "$(jq -r '.choices[0]|.message' \
                      <(sed '$ d' <<< "${response}"))" '.messages += [$message]' <<< "${OPENAI_CHAT}"`
                    ;;
                *)
                    # Return the response
                    echo "$(basename "${func_source}"): <${http_code}> $(jq -r '.error | "\(.type) - \(.message)"' \
                      <(sed '$ d' <<< "${response}"))"
                    return 1;;
            esac

            # Cache the response (fresh).
            install -m 644 -D <(echo "${OPENAI_CHAT}") "${cache}/${hash}"
        else
            # Return the cached content.
            OPENAI_CHAT=`jq -r --argjson messages \
              "$(jq -rc '[.messages[0], .messages[-2:][]]' "${cache}/${hash}")" '.messages |= $messages' \
              <<< "${OPENAI_CHAT}"`
        fi

        # Return the response message content.
        if type "${MARKDOWN:-glow}" >/dev/null 2>&1; then
            jq -r '.messages|last|.content' <<< "${OPENAI_CHAT}" | "${MARKDOWN:-glow}"
        else
            # MARKDOWN cmd not found (raw output).
            echo
            jq -r '.messages|last|.content' <<< "${OPENAI_CHAT}"
            echo
        fi

    } || {
        # Something went wrong.
        echo >&2 "${func_source} - \${OPENAI_CHAT} is not valid json."
        return 1
    }
}
