#!/bin/env -S bash
# Shell script to interface to the OpenAI API's.
# This script builds json from user input and returns model generated messages.

# Enable for debuging
#set -x

# Verify script requirements.
for req in ansible-vault curl glow tput jq yq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Read credentials from vault.
[[ -f "${HOME}/.loginrc.vault" && "${HOME}/.vaultpw" ]] && {
    OPENAI_API_KEY=`yq -r '.OPENAI_API_KEY' \
      <(ansible-vault view "${HOME}/.loginrc.vault" --vault-password-file "${HOME}/.vaultpw")`
} || {
    echo "$(basename "${0}"): Unable to get creds from vault."
    exit 1;
}

function openai_chat() {
    # Return a model response from chat_data.
    ## https://platform.openai.com/docs/api-reference/chat

    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Start chat_data if none exists.
    [[ -z "${chat_data}" ]] && {
        chat_data="$(jq --null-input --arg model "${OPENAI_MODEL:-gpt-3.5-turbo}" \
            --arg prompt "${OPENAI_PROMPT:-You are a helpful assistant.}" \
            --arg temp "${OPENAI_TEMP:-0.7}" \
            --arg tokens "${OPENAI_TOKENS:-1900}" \
            --arg user "$(whoami)" '{
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
    }

    # Validate chat_data variable is good.
    jq -e '.' >/dev/null 2>&1 <<<${chat_data:-ERR} > /dev/null && {

        # Read user input if no variable.
        [[ -z "${user_input}" ]] && {
            tput setaf 2 && while IFS= read -r input; do
                case "${input}" in
                    $'\004') break ;; # CTRL+D
                    'debug') jq '.' <<<${chat_data} ;;
                    *) user_input+=("$input") ;;
                esac
            done && tput sgr0
        }

        # Append user_input to chat_data variable.
        [[ ! -z "${user_input[@]}" ]] && {
            CACHE="${HOME}/.cache/$(basename "${FUNC_SOURCE}")"
            HASH="$(awk '{$1=$1};1' <<<${user_input[@],,} | md5sum -t | awk '{print $1}')"

            chat_data=`jq -c --arg input "$(echo -e "${user_input[@]}")" \
              '.messages += [{"role": "user", "content": $input}]' <<<${chat_data}`
            unset user_input
        } || { exit 0; }

        # Fetch the response & cache (requery if previous cache is +30 days old).
        if [[ ! -f "${CACHE}/${HASH}" ]] || [[ $(find "${CACHE}/${HASH}" -mtime +30 -print) ]]; then
            response=$(curl --silent --insecure --location --write-out "%{http_code}" \
              --request POST --url "https://api.openai.com/v1/chat/completions" \
              --header "Content-Type: application/json" --header "Authorization: Bearer ${OPENAI_API_KEY}" \
              --data "${chat_data:-{\}}")
            http_code=$(tail -n1 <<<${response})

            # Handle the response or error code.
            case "${http_code}" in
                200)
                    # Return the content (fresh).
                    chat_data=`jq -c --argjson message "$(jq -r '.choices[0]|.message' \
                      <(sed '$ d' <<<${response}))" '.messages += [$message]' <<<${chat_data}`
                    ;;
                *)
                    # Return the response
                    echo "$(basename "${FUNC_SOURCE}"): <${http_code}> $(jq -r '.error | "\(.type) - \(.message)"' \
                      <(sed '$ d' <<<${response}))"
                    exit 1;;
            esac

            # Cache the response.
            install -m 644 -D <(echo "${chat_data}") "${CACHE:-openai_chat}/${HASH}"
        else
            # Read the last cached responce.
            response="$(jq -c '.messages|last' "${CACHE}/${HASH}")"

            # Return the content (cached).
            chat_data=`jq -c --argjson message "${response}" '.messages += [$message]' <<<${chat_data}`
        fi

        # Return the last message content.
        jq -r '.messages|last|.content' <<<${chat_data} | glow && echo

    } || {
        # Something went wrong.
        echo "$(basename "${FUNC_SOURCE}"): \${chat_data} is not valid json."
    }
}

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
                    response=`jq -c --arg prompt "${user_input}" '. += {"prompt": $prompt|tostring}' <(sed '$ d' <<<${response})`

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
            --arg n "${OPENAI_N:-1}" --arg user "$(whoami)" '{
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

# Entry point to script functions.
[[ "${OPENAI_API_KEY}" = "sk-"* ]] && {

    # Use args or stdin as input.
    [[ -t 0 ]] && {
        user_input="${@}"
    } || {
        user_input=$(</dev/stdin)
    }

    # Return a model responses from interactive chat.
    if [[ -z "${user_input}" ]]; then
    ## Multi-turn conversation.
    cat <<-EOF | sed 's/^[ \t]*//' | glow
        # $(basename "${0}")
        > MODEL: \${OPENAI_MODEL} **(${OPENAI_MODEL:-gpt-3.5-turbo})**
        > PROMPT: \${OPENAI_PROMPT} *(${OPENAI_PROMPT:-You are a helpful assistant.})*
        > TEMPRATURE: \${OPENAI_TEMP} (${OPENAI_TEMP:-0.7})
        > MAX_TOKENS: \${OPENAI_TOKENS} (${OPENAI_TOKENS:-1900})
        
        Paste your multi-line text into the terminal, press \`CTRL+D\` when finished.
	EOF

        # Loop the chat function.
        while true; do openai_chat; done

    elif [[ "${user_input,,}" == "image"* ]]; then
        ## generate a new image (256x256, 512x512, or 1024x1024)
        OPENAI_FORMAT=url
        openai_images

    else
        ## text_completion without any conversation.
        #openai_chat
        openai_completions
    fi

} || {
    echo "$(basename "${0}"): \${OPENAI_API_KEY} is not set or invalid."
}
