## stoppoll # Use this method to stop a poll which was sent by the bot.
# https://core.telegram.org/bots/api#stoppoll

function stopPoll ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "$(grep -E "+{*}+" <<<${1:-{\}} 2> /dev/null)" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to stop a poll which was sent by the bot.
	Ref: https://core.telegram.org/bots/api#stoppoll
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to stop a poll which was sent by the bot. On success,
the stopped Poll is returned.
  Parameter      Type                   Required   Description
  -------------- ---------------------- ---------- ------------------------------------------------------------------------------------------------------------
  chat_id        Integer or String      Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
  message_id     Integer                Yes        Identifier of the original message with the poll
  reply_markup   InlineKeyboardMarkup   Optional   A JSON-serialized object for a new message inline keyboard.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/stopPoll\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
