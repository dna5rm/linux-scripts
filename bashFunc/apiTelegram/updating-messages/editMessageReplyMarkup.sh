## editmessagereplymarkup # Use this method to edit only the reply markup of messages.
# https://core.telegram.org/bots/api#editmessagereplymarkup

function editMessageReplyMarkup ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to edit only the reply markup of messages.
	Ref: https://core.telegram.org/bots/api#editmessagereplymarkup
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to edit only the reply markup of messages. On success,
if the edited message is not an inline message, the edited Message is
returned, otherwise *True* is returned.
  Parameter           Type                   Required   Description
  ------------------- ---------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------
  chat_id             Integer or String      Optional   Required if *inline_message_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
  message_id          Integer                Optional   Required if *inline_message_id* is not specified. Identifier of the message to edit
  inline_message_id   String                 Optional   Required if *chat_id* and *message_id* are not specified. Identifier of the inline message
  reply_markup        InlineKeyboardMarkup   Optional   A JSON-serialized object for an inline keyboard.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/editMessageReplyMarkup\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
