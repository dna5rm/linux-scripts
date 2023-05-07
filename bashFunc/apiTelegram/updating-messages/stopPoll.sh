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

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to stop a poll which was sent by the bot.
	Ref: https://core.telegram.org/bots/api#stoppoll
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
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/stopPoll" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
