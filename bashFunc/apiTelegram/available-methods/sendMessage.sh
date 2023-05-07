## sendmessage # Use this method to send text messages.
# https://core.telegram.org/bots/api#sendmessage

function sendMessage ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send text messages.
	Ref: https://core.telegram.org/bots/api#sendmessage
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to send text messages. On success, the sent Message is
	returned.
	
	  Parameter                     Type                                                                               Required   Description
	  ----------------------------- ---------------------------------------------------------------------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                       Integer or String                                                                  Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_thread_id             Integer                                                                            Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
	  text                          String                                                                             Yes        Text of the message to be sent, 1-4096 characters after entities parsing
	  parse_mode                    String                                                                             Optional   Mode for parsing entities in the message text. See formatting options for more details.
	  entities                      Array of MessageEntity                                                             Optional   A JSON-serialized list of special entities that appear in message text, which can be specified instead of *parse_mode*
	  disable_web_page_preview      Boolean                                                                            Optional   Disables link previews for links in this message
	  disable_notification          Boolean                                                                            Optional   Sends the message silently. Users will receive a notification with no sound.
	  protect_content               Boolean                                                                            Optional   Protects the contents of the sent message from forwarding and saving
	  reply_to_message_id           Integer                                                                            Optional   If the message is a reply, ID of the original message
	  allow_sending_without_reply   Boolean                                                                            Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
	  reply_markup                  InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply   Optional   Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
