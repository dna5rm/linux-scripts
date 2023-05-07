## sendpoll # Use this method to send a native poll.
# https://core.telegram.org/bots/api#sendpoll

function sendPoll ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send a native poll.
	Ref: https://core.telegram.org/bots/api#sendpoll
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to send a native poll. On success, the sent Message is
	returned.
	
	  Parameter                     Type                                                                               Required   Description
	  ----------------------------- ---------------------------------------------------------------------------------- ---------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                       Integer or String                                                                  Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_thread_id             Integer                                                                            Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
	  question                      String                                                                             Yes        Poll question, 1-300 characters
	  options                       Array of String                                                                    Yes        A JSON-serialized list of answer options, 2-10 strings 1-100 characters each
	  is_anonymous                  Boolean                                                                            Optional   *True*, if the poll needs to be anonymous, defaults to *True*
	  type                          String                                                                             Optional   Poll type, "quiz" or "regular", defaults to "regular"
	  allows_multiple_answers       Boolean                                                                            Optional   *True*, if the poll allows multiple answers, ignored for polls in quiz mode, defaults to *False*
	  correct_option_id             Integer                                                                            Optional   0-based identifier of the correct answer option, required for polls in quiz mode
	  explanation                   String                                                                             Optional   Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters with at most 2 line feeds after entities parsing
	  explanation_parse_mode        String                                                                             Optional   Mode for parsing entities in the explanation. See formatting options for more details.
	  explanation_entities          Array of MessageEntity                                                             Optional   A JSON-serialized list of special entities that appear in the poll explanation, which can be specified instead of *parse_mode*
	  open_period                   Integer                                                                            Optional   Amount of time in seconds the poll will be active after creation, 5-600. Can't be used together with *close_date*.
	  close_date                    Integer                                                                            Optional   Point in time (Unix timestamp) when the poll will be automatically closed. Must be at least 5 and no more than 600 seconds in the future. Can't be used together with *open_period*.
	  is_closed                     Boolean                                                                            Optional   Pass *True* if the poll needs to be immediately closed. This can be useful for poll preview.
	  disable_notification          Boolean                                                                            Optional   Sends the message silently. Users will receive a notification with no sound.
	  protect_content               Boolean                                                                            Optional   Protects the contents of the sent message from forwarding and saving
	  reply_to_message_id           Integer                                                                            Optional   If the message is a reply, ID of the original message
	  allow_sending_without_reply   Boolean                                                                            Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
	  reply_markup                  InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply   Optional   Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendPoll" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
