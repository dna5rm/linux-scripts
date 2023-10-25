#!/bin/env -S bash
# Shell script to interface to the OpenAI API's.
# This script builds json from user input and returns model generated messages.

## Bash functions to load.
bashFunc=(
    "openai_chat"
    "openai_completions"
    "openai_images"
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
        
        Enter your multi-line text. Press \`CTRL+D\` on a newline when finished or \`CTRL+C\` to cancel.
	EOF

        # Loop the chat function.
        while true; do openai_chat; done

    elif [[ "${user_input,,}" == "image"* ]]; then
        ## generate a new image (256x256, 512x512, or 1024x1024)
        OPENAI_FORMAT=url
        openai_images &
        wait_animation

    else
        ## text_completion without any conversation.
        #openai_chat
        openai_completions &
        wait_animation
    fi

} || {
    echo "$(basename "${0}"): \${OPENAI_API_KEY} is not set or invalid."
}
