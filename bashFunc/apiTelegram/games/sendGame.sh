## sendgame # Use this method to send a game.
# https://core.telegram.org/bots/api#sendgame

function sendGame ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send a game.
	Ref: https://core.telegram.org/bots/api#sendgame
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to send a game. On success, the sent Message is
returned.
  Parameter                     Type                   Required   Description
  ----------------------------- ---------------------- ---------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
  chat_id                       Integer                Yes        Unique identifier for the target chat
  message_thread_id             Integer                Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
  game_short_name               String                 Yes        Short name of the game, serves as the unique identifier for the game. Set up your games via \@BotFather.
  disable_notification          Boolean                Optional   Sends the message silently. Users will receive a notification with no sound.
  protect_content               Boolean                Optional   Protects the contents of the sent message from forwarding and saving
  reply_to_message_id           Integer                Optional   If the message is a reply, ID of the original message
  allow_sending_without_reply   Boolean                Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
  reply_markup                  InlineKeyboardMarkup   Optional   A JSON-serialized object for an inline keyboard. If empty, one \'Play game_title\' button will be shown. If not empty, the first button must launch the game.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendGame\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
