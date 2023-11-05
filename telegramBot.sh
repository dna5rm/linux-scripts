#!/bin/env -S bash

## Bash functions to load.
bashFunc=(
    "alpaca_completions"
    "openai_completions"
    "err_report"
    "log_message"
    "apiTelegram/getMe"
    "apiTelegram/getUpdates"
    "apiTelegram/sendMessage"
)

## Load external functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

# Load internal functions.
function tg_chatbot() {
    # build prompt from input.
    [[ -z "${reply}" ]] && {
        local user_input="${name:-null} in a ${type/super/} chat is asking... ${message} ... You are direct, to the point and will never exceed 4000 charcters!"
    } || {
        local user_input="You just posted... ${reply} ... ${name:-null} in a ${type/super/} chat responded... ${message} ... You are direct, to the point and will never exceed 4000 charcters!"
    }

    #reply=`alpaca_completions`
    reply=`openai_completions`

    json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
    json="$(jq --arg text "${reply:0:4096}" '. + {"text": $text}' <<<${json:-{\}})"

    output=`jq -c '.' <(sendMessage "${json}")`
    jq -c '.' <<< "${output}" && log_message sendMessage "${output}"

}

# Read credentials from vault.
[[ -f "${HOME}/.${USER:-loginrc}.vault" && "${HOME}/.vault" ]] && {
    OPENAI_API_KEY=`yq -r '.OPENAI_API_KEY' \
      <(ansible-vault view "${HOME}/.${USER:-loginrc}.vault" --vault-password-file "${HOME}/.vault")`
    TELEGRAM_TOKEN=`yq -r '.TELEGRAM_TOKEN' \
      <(ansible-vault view "${HOME}/.${USER:-loginrc}.vault" --vault-password-file "${HOME}/.vault")`
} || {
    echo "$(basename "${0}"): Unable to get creds from vault."
    exit 1;
}

# Set script vars.
getMe=`getMe`
MARKDOWN=null

# Test if access token is good and start script.
[[ "$(jq '.is_bot' <<< "${getMe}")" != "true" ]] && {
    echo >&2 "$(basename "${0}") - Telegram bot access token failure."
} || {

    # Run within an infinite loop.
    while true; do

        # Load previously stored offset variable.
        test -f "${HOME}/.cache/$(basename "${0%.*}").offset" && read offset < "${HOME}/.cache/$(basename "${0%.*}").offset" || unset offset

        # Get latest telegram updates.
        jq -rc '.[]' <(getUpdates "{\"offset\": ${offset:-0}}") | while read update; do

            # Store the latest update_id+1 for offset.
            install -m 644 -D <(jq '.update_id+1' <<< "${update}") "${HOME}/.cache/$(basename "${0%.*}").offset"

            log_message getUpdates "${update}"

            # Set loop variables from latest update.
            chat_id=`jq '.message.chat.id' <<< "${update}"`
            command=`jq -r '.message.entities[0].type // empty' <<< "${update}"`
            message=`jq -r '.message.text' <<< "${update}"`
            message_id=`jq '.message.message_id' <<< "${update}"`
            name=`jq -r '.message.from.first_name' <<< "${update}"`
            type=`jq -r '.message.chat.type' <<< "${update}"`
            reply=`jq -r 'try(.message.reply_to_message.text) // empty' <<< "${update}"`

            # command is missing / private chat.
            if [[ -z "${command}" ]]; then

                tg_chatbot

            elif [[ "${command}" == "bot_command" ]]; then

                case "${message%% *}" in
                    "/ask")
                        message="${message#* }"
                        tg_chatbot
                        ;;
                esac

            else
                reply="Sorry, I do not understand."

                json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
                json="$(jq --arg text "${reply:0:4096}" '. + {"text": $text}' <<<${json:-{\}})"

                sendMessage "${json}" | jq -c '.'
            fi
            unset json reply

        # Sleep 15 seconds before next run.
        done && sleep 15
    done
}
