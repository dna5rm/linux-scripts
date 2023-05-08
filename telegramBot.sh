#!/bin/env -S bash

## Bash functions to load.
bashFunc=(
    "askAlpaca"
    "apiTelegram/getMe"
    "apiTelegram/getChat"
    "apiTelegram/getUpdates"
    "apiTelegram/sendMessage"
)

## Load Bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

## Set variables.
alpaca_model="${HOME}/opt/ggml-alpaca-7b-q4.bin"
cacheDir="${HOME}/.cache/$(basename "${0}")"
TELEGRAM_TOKEN="$(awk '/telegram/{print $NF}' ~/.netrc)"

## Main Script - Initialization
[[ ! -f "${cacheDir}/getme.json" ]] && {
    install -m 644 -D <(getMe | jq '.') "${cacheDir}/getMe.json"
} && getMe=( $(jq -r '[ .ok, .result.id, .result.is_bot, .result.first_name ] | @tsv' "${cacheDir}/getMe.json") )

[[ "${getMe[0]}" == "true" ]] && {

    while true; do

        # Get the most recent update_id.
        [[ -s "${cacheDir}/getUpdates.json" ]] && {
            updateLast="$(jq -c '.[]' "${cacheDir}/getUpdates.json" | awk 'END{print}' | jq -r '.update_id')"
        }

        install -m 644 -D <(getUpdates '{"offset": '''${updateLast}'''}' | jq -c '.result') "${cacheDir}/getUpdates.json"

        jq -r '.[] | select(.message.from.is_bot == false) | [.update_id, .message.from.username, .message.chat.id, .message.chat.type, .message.entities[0].type // "null", .message.text] | @tsv' "${cacheDir}/getUpdates.json" |\
         while read id name chat_id type is_command message; do

            [[ "${id}" -gt "${updateLast:-0}" ]] && {

                echo "[$(date +'%r')] ${updateLast}/${id} ${name} ${chat_id} ${type} ${is_command} :: ${message%% *}|${message#* }"

                # Respond to private chats with Alpaca.
                if [[ "${type,,}" == "private" ]] && [[ "${is_command}" == "null" ]]; then
                    reply="$(askAlpaca "${name} in a ${type} chat asked: ${message}")"

                    json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
                    json="$(jq --arg text "${reply:0:4096}" '. + {"text": $text}' <<<${json:-{\}})"

                    sendMessage "${json}" | jq -c '.'

                # Respond to /ask commands with Alpaca.
                elif [[ "${message%% *}" == "/ask" ]]; then
                   reply="$(askAlpaca "${name} in a public group chat asked: ${message#* }")"

                   json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
                   json="$(jq --arg text "${reply:0:4096}" '. + {"text": $text}' <<<${json:-{\}})"

                   sendMessage "${json}" | jq -c '.'

                else
                    reply="Sorry, I do not understand."

                    json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
                    json="$(jq --arg text "${reply:0:4096}" '. + {"text": $text}' <<<${json:-{\}})"

                    install -m 644 -D <(getChat '{"chat_id": '''${chat_id}'''}' | jq -c '.') "${cacheDir}/debug.${chat_id}-getChat.json"
                    sendMessage "${json}" | tee "${cacheDir}/debug.${chat_id}-sendMessage.json" | jq -c '.'
                fi
                unset json
            }

        done

    done
}
