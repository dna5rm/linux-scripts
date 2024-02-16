#!/bin/bash
# Shell script to interface to the OpenAI API's.
# This script builds json from user input and returns model generated messages.

## Bash functions to load.
bashFunc=(
    "openai_chat"
    "openai_completions"
    "openai_images"
    "vault"
    "wait_animation"
)

## Load bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

# Verify script requirements.
for req in curl glow vault_view; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done && umask 0077

# Read credentials from vault.
if [[ -z "${OPENAI_API_KEY}" ]] && type vault_view >/dev/null 2>&1; then
    OPENAI_API_KEY=`yq -r '.OPENAI_API_KEY' <(vault_view)`
elif [[ -z "${OPENAI_API_KEY}" ]]; then
    echo "[$(basename "${0}")] Unable to get creds from vault."
    exit 1;
fi

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
    sed 's/^[ \t]*//' <<-EOF | glow
        # $(basename "${0}")
        > MODEL: \${OPENAI_MODEL} **(${OPENAI_MODEL:-gpt-3.5-turbo})**
        > PROMPT: \${OPENAI_PROMPT} *(${OPENAI_PROMPT:-You are a helpful assistant.})*
        > TEMPRATURE: \${OPENAI_TEMP} (${OPENAI_TEMP:-0.7})
        > MAX_TOKENS: \${OPENAI_TOKENS} (${OPENAI_TOKENS:-1900})
        
        Enter your multi-line text. Press \`CTRL+D\` on a newline when finished or \`CTRL+C\` to cancel.
	EOF

        # Loop the chat function.
        while true; do openai_chat; done

    elif [[ "${user_input,,}" == "image"* ]]; then
        ## generate a new image (256x256, 512x512, or 1024x1024)
        OPENAI_FORMAT=url
        openai_images

    else
        ## Single-turn without any conversation.
        OPENAI_MODEL="gpt-4-turbo-preview"
        wait_animation openai_chat

        ## text completion (legacy).
        # OPENAI_MODEL="text-davinci-003"
        #wait_animation openai_completions
    fi

} || {
    echo "$(basename "${0}"): \${OPENAI_API_KEY} is not set or invalid."
}
