function openai_completions() {
    # Return a completion response from provided prompt. (Legacy)
    ## https://platform.openai.com/docs/api-reference/completions

    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Build prompt arguments from user_input.
    [[ ! -z "${user_input}" ]] && {
        prompt_data="$(jq --null-input --arg model "${OPENAI_MODEL:-gpt-3.5-turbo-instruct}" \
            --arg prompt "${user_input}" \
            --arg temp "${OPENAI_TEMP:-0.7}" \
            --arg tokens "${OPENAI_TOKENS:-1900}" \
            --arg user "$(whoami)" '{
          "model": $model|tostring,
          "prompt": $prompt|tostring,
          "echo": false,
          "max_tokens": $tokens|tonumber,
          "temperature": $temp|tonumber,
          "user": $user|tostring
        }')"
    }

    # Create a hash of arguments for caching.
    CACHE="${HOME}/.cache/$(basename "${FUNC_SOURCE}")"
    HASH="$(awk '{$1=$1};1' <<<${user_input[@],,} | md5sum -t | awk '{print $1}')"

    # Validate chat_data variable is good.
    jq -e '.' >/dev/null 2>&1 <<<${prompt_data:-ERR} > /dev/null && {

        # Fetch the response & cache (requery if previous cache is +30 days old).
        if [[ ! -f "${CACHE}/${HASH}" ]] || [[ $(find "${CACHE}/${HASH}" -mtime +30 -print) ]]; then
            response=$(curl --silent --insecure --location --write-out "%{http_code}" \
              --request POST --url "https://api.openai.com/v1/completions" \
              --header "Content-Type: application/json" --header "Authorization: Bearer ${OPENAI_API_KEY}" \
              --data "${prompt_data:-{\}}")
            http_code=$(tail -n1 <<<${response})

            # Handle the response or error code.
            case "${http_code}" in
                200)
                    # Add prompt used to the response.
                    response=`jq -c --arg prompt "${user_input}" '. += {"prompt": $prompt|tostring}' \
                      <(sed '$ d' <<<${response})`

                    # Cache the response (fresh).
                    install -m 644 -D <(jq -c '.' <<<${response}) "${CACHE:openai_completions}/${HASH}"
                    ;;
                *)
                    # Return the message.
                    echo "$(basename "${FUNC_SOURCE}"): <${http_code}> $(jq -r '.error | "\(.type) - \(.message)"' \
                      <(sed '$ d' <<<${response}))"
                    exit 1;;
            esac
        else
            # Read the last cached response.
            response="$(awk 'END{print}' "${CACHE:openai_completions}/${HASH}")"
        fi

        # Return the first choice text.
        jq -r '. | "# "+ .model, "", .choices[0].text' <<<${response} | glow && echo

    } || {
        # Something went wrong.
        echo "$(basename "${FUNC_SOURCE}"): \${prompt_data} is not valid json."
    }
}
