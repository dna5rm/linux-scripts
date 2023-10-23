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
            --arg tokens "${OPENAI_TOKENS:-256}" \
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
    jq -e '.' >/dev/null 2>&1 <<<${chat_data} > /dev/null && {

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
            HASH="$(echo "${user_input[@],,}" | md5sum -t | awk '{print $1}')"

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
                400)
                    # Return the response
                    echo "$(basename "${FUNC_SOURCE}"): $(jq -r '.error | "\(.type) - \(.message)"' \
                      <(sed '$ d' <<<${response}))"
                    exit 1;;
                *)
                    # Return the content (fresh).
                    chat_data=`jq -c --arg content "$(jq -r '.choices[0]|.message.content' \
                      <(sed '$ d' <<<${response}))" '.messages += [{"role": "assistant", "content": $content}]' \
                      <<<${chat_data}`
                    ;;
            esac

            # Cache the response.
            install -m 644 -D <(echo "${chat_data}") "${CACHE:-openai_chat}/${HASH}"
        else
            # Read the cached responce.
            response="$(printf "$(sed -n \
              '/{\"role\":\"assistant\",\"content\":\"/,/\"}],\"/ {s/.*"content":\"//;s/\"}].*,\".*//;p}' \
              "${CACHE}/${HASH}")")"

            # Return the content (cached).
            chat_data=`jq -c --arg content "${response}" \
              '.messages += [{"role": "assistant", "content": $content}]' <<<${chat_data}`
        fi

        # Return the last message content.
        jq -r '.messages|last|.content' <<<${chat_data} | glow && echo

    } || {
        # Something went wrong.
        echo "$(basename "${FUNC_SOURCE}"): \${chat_data} is not valid json."
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
        > MAX_TOKENS: \${OPENAI_TOKENS} (${OPENAI_TOKENS:-256})
        
        Paste your multi-line text into the terminal, press \`CTRL+D\` when finished.
	EOF

        # Loop the chat function.
        while true; do
            openai_chat
        done

    else
        ## Single-turn without any conversation.
        openai_chat
    fi

} || {
    echo "$(basename "${0}"): \${OPENAI_API_KEY} is not set or invalid."
}
