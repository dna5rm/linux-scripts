function openai_images() {
    # Return an image generated	from user provided content.
    ## https://platform.openai.com/docs/api-reference/images

    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Build prompt arguments from user_input.
    [[ ! -z "${user_input}" ]] && {
        # Extract the image size if provided.
        [[ $(awk '{print tolower($1)}' <<<${user_input}) =~ image:([0-9]+x[0-9]+) ]] && {
            [[ $(grep -E "\b(256x256|512x512|1024x1024)\b" <<<${BASH_REMATCH[1]}) ]] && {
                OPENAI_SIZE="${BASH_REMATCH[1]}"
            }
        }

        # Ignore the first word from the user_input.
        prompt_data="$(jq --null-input --arg prompt "${user_input#* }" \
            --arg response "${OPENAI_FORMAT:-b64_json}" \
            --arg size "${OPENAI_SIZE:-256x256}" \
            --arg n "${OPENAI_N:-1}" --arg user "$(whoami):${FUNC_SOURCE}" '{
          "prompt": $prompt|tostring,
          "n": $n|tonumber,
          "response_format": $response|tostring,
          "size": $size|tostring,
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
              --request POST --url "https://api.openai.com/v1/images/generations" \
              --header "Content-Type: application/json" --header "Authorization: Bearer ${OPENAI_API_KEY}" \
              --data "${prompt_data:-{\}}")
            http_code=$(tail -n1 <<<${response})

            # Handle the response or error code.
            case "${http_code}" in
                200)
                    # Add prompt used to the response.
                    response=`jq -c --arg prompt "${user_input}" '. += {"prompt": $prompt|tostring}' \
                      <(sed '$ d' <<<${response})`

                    # Check the response data type.
                    [[ "$(jq -r '.data[0]|keys[]' <<<${response})" == "url" ]] && {
                        # Return the first choice image if url (no cache).
                        jq -r '.data[0].url' <<<${response}
                    } || {
                        # Cache the response (fresh).
                        install -m 644 -D <(jq -c '.' <<<${response}) "${CACHE:openai_images}/${HASH}"
                    };;
                *)
                    # Return the message.
                    echo "$(basename "${FUNC_SOURCE}"): <${http_code}> $(jq -r '.error | "\(.type) - \(.message)"' \
                      <(sed '$ d' <<<${response}))"
                    exit 1;;
            esac
        else
            # Read the last cached response.
            response="$(awk 'END{print}' "${CACHE:openai_images}/${HASH}")"
        fi

        # Return image if b64_json.
        if [[ "$(jq -r '.data[0]|keys[]' <<<${response})" == "b64_json" ]]; then
            jq -r '.data[0].b64_json' <<<${response}
        fi

    } || {
        # Something went wrong.
        echo "$(basename "${FUNC_SOURCE}"): \${prompt_data} is not valid json."
    }
}
