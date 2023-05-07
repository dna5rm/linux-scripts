## callbackquery # This object represents an incoming callback query from a callback button in an inline keyboard.
# https://core.telegram.org/bots/api#callbackquery

function CallbackQuery ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an incoming callback query from a callback button in an inline keyboard.
	Ref: https://core.telegram.org/bots/api#callbackquery
	---
	This object represents an incoming callback query from a callback button
	in an inline keyboard. If the button that originated the query was
	attached to a message sent by the bot, the field *message* will be
	present. If the button was attached to a message sent via the bot (in
	inline mode), the field *inline_message_id* will be present. Exactly one
	of the fields *data* or *game_short_name* will be present.
	
	  Field               Type      Description
	  ------------------- --------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  id                  String    Unique identifier for this query
	  from                User      Sender
	  message             Message   *Optional*. Message with the callback button that originated the query. Note that message content and message date will not be available if the message is too old
	  inline_message_id   String    *Optional*. Identifier of the message sent via the bot in inline mode, that originated the query.
	  chat_instance       String    Global identifier, uniquely corresponding to the chat to which the message with the callback button was sent. Useful for high scores in games.
	  data                String    *Optional*. Data associated with the callback button. Be aware that the message originated the query can contain no callback buttons with this data.
	  game_short_name     String    *Optional*. Short name of a Game to be returned, serves as the unique identifier for the game
	
	> **NOTE:** After the user presses a callback button, Telegram clients
	> will display a progress bar until you call answerCallbackQuery. It is,
	> therefore, necessary to react by calling answerCallbackQuery even if
	> no notification to the user is needed (e.g., without specifying any of
	> the optional parameters).
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/CallbackQuery" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
