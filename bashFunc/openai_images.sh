# Return an image generated from user provided content.
## https://platform.openai.com/docs/api-reference/images

function openai_images() {

    # Get the function source.
    local func_source="${FUNCNAME[0]}"

    # Use user_input var, args or stdin as input.
    [[ -z "${user_input}" ]] && {
        [[ -t 0 ]] && {
            local user_input="${@}"
        } || {
            local user_input=$(</dev/stdin)
        }

        # Extract the image size if provided.
        [[ $(awk '{print $1}' <<< "${user_input,,}") =~ image:([0-9]+x[0-9]+) ]] && {
            [[ $(grep -E "\b(256x256|512x512|1024x1024)\b" <<< "${BASH_REMATCH[1]}") ]] && {
                local size="${BASH_REMATCH[1]}"
            }
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
        # Ignore the first word from the user_input.
        local openai_data="$(jq --null-input --arg prompt "${user_input#* }" \
          --arg response "${OPENAI_FORMAT:-b64_json}" \
          --arg size "${size:-256x256}" \
          --arg n "${OPENAI_N:-1}" \
          --arg user "$(md5sum -t <(printf "%s:${func_source}" `whoami`) | awk '{print $1}')" '{
            "prompt": $prompt|tostring,
            "n": $n|tonumber,
            "response_format": $response|tostring,
            "size": $size|tostring,
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
              --request POST --url "https://api.openai.com/v1/images/generations" \
              --header "Content-Type: application/json" --header "Authorization: Bearer ${OPENAI_API_KEY}" \
              --data "${openai_data:-{\}}")

            # Handle the response or error code.
            local http_code=$(tail -n1 <<< "${response}")
            case "${http_code}" in
                200)
                    # Add prompt used to the response.
                    local response=`jq -c --arg prompt "${user_input}" '. += {"prompt": $prompt|tostring}' \
                      <(sed '$ d' <<< "${response}")`

                    # Check the response data type.
                    [[ "$(jq -r '.data[0]|keys[]' <<< "${response}")" == "url" ]] && {
                        # Return the first choice image if url (no cache).
                        jq -r '.data[0].url' <<< "${response}"
                    } || {
                        # Cache the response (fresh).
                        install -m 644 -D <(jq -c '.' <<< "${response}") "${cache}/${hash}"
                    };;
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

        # Return image if b64_json.
        if [[ "$(jq -r '.data[0]|keys[]' <<< "${response}")" == "b64_json" ]]; then
            jq -r '.data[0].b64_json' <<< "${response}"
        fi

    } || {
        # Something went wrong.
        echo >&2 "${func_source} - \${openai_data} is not valid json."
        return 1
    }
}
