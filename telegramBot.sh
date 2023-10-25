#!/bin/env -S bash

## Bash functions to load.
bashFunc=(
    "y2j"
    "apiTelegram/getMe"
    "apiTelegram/getChat"
    "apiTelegram/getUpdates"
    "apiTelegram/sendMessage"
    "apiTelegram/sendPhoto"
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

## Read credentials from vault.
[[ -f "${HOME}/.loginrc.vault" && "${HOME}/.vaultpw" ]] && {
    OPENAI_API_KEY=`yq -r '.OPENAI_API_KEY' <(ansible-vault view "${HOME}/.loginrc.vault" --vault-password-file "${HOME}/.vaultpw")`
    TELEGRAM_TOKEN="$(awk '/telegram/{print $NF}' ~/.netrc)"
} || {
    echo "$(basename "${0}"): Unable to get creds from vault."
    exit 1;
}

## Set variables.
alpaca_model="${HOME}/opt/ggml-alpaca-7b-q4.bin"
cacheDir="${HOME}/.cache/$(basename "${0}")"

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

        install -m 644 -D <(getUpdates '{"offset": '''${updateLast:-0}'''}' | jq -c '.result') "${cacheDir}/getUpdates.json"

        jq -r '.[] | select(.message.from.is_bot == false) | [.update_id, .message.message_id, .message.reply_to_message.message_id // "null", .message.from.first_name, .message.chat.id, .message.chat.type, .message.entities[0].type // "null", .message.text] | @tsv' "${cacheDir}/getUpdates.json" |\
         while read id message_id reply_id name chat_id type is_command message; do

            [[ "${id:-0}" -gt "${updateLast:-1}" ]] && {

                echo "[$(date +'%r')] ${updateLast:-0}/${id} ${name:-null} ${chat_id} ${type} ${is_command} :: ${message%% *}|${message#* }" |\
                 tee -a "${cacheDir}/${getMe[3]/$/}.log"

                # Respond to chats with Alpaca.
                if [[ "${is_command}" == "null" ]]; then
                    prompt+=( "${name:-null} in a ${type/super/} chat is asking: ${message}" )

                    reply="$(ask_alpaca.sh "${prompt[@]}")"
                    #reply="$(ask_openai.sh "${prompt[@]}" | jq -r '.choices[0].text')"

                    json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
                    json="$(jq --arg text "${reply:0:4096}" '. + {"text": $text}' <<<${json:-{\}})"

                    sendMessage "${json}" | jq -c '.'

                # Command: /ask - Respond with responce from Alpaca.
                elif [[ "${message%% *}" == "/ask" ]]; then
                   reply="$(ask_alpaca.sh "${name:-null} in a public group chat asked: ${message#* }")"

                   json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
                   json="$(jq --arg text "${reply:0:4096}" '. + {"text": $text}' <<<${json:-{\}})"

                   sendMessage "${json}" | jq -c '.'

                # Command: /img - Respond with OpenAI generated image.
#                elif [[ "${message%% *}" == "/img" ]]; then
#                   photo="${cacheDir}/$(uuid).png"
#
#                   install -m 644 -D <(askOpenAI "image ${message#* }" | jq -r '.data[0].b64_json' | base64 -d) "${photo}"
#
#                   json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
#                   json="$(jq --arg photo "@${photo}" '. + {"photo": $photo}' <<<${json:-{\}})"
#                   json="$(jq --arg caption "$(file -b "${photo}")" '. + {"caption": $caption}' <<<${json:-{\}})"
#
#                   sendPhoto "${json}" | jq -c '.'

                else
                    reply="Sorry, I do not understand."

                    json="$(jq --arg chat_id "${chat_id}" '. + {"chat_id": $chat_id}' <<<${json:-{\}})"
                    json="$(jq --arg text "${reply:0:4096}" '. + {"text": $text}' <<<${json:-{\}})"

                    sendMessage "${json}" | jq -c '.'
                fi
                unset json
            }

        done

    done
}
