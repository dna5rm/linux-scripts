## sendphoto # Use this method to send photos.
# https://core.telegram.org/bots/api#sendphoto

function sendPhoto ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send photos.
	Ref: https://core.telegram.org/bots/api#sendphoto
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to send photos. On success, the sent Message is
returned.
  Parameter                     Type                                                                               Required   Description
  ----------------------------- ---------------------------------------------------------------------------------- ---------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  chat_id                       Integer or String                                                                  Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
  message_thread_id             Integer                                                                            Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
  photo                         InputFile or String                                                                Yes        Photo to send. Pass a file_id as String to send a photo that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a photo from the Internet, or upload a new photo using multipart/form-data. The photo must be at most 10 MB in size. The photo\'s width and height must not exceed 10000 in total. Width and height ratio must be at most 20. More information on Sending Files »
  caption                       String                                                                             Optional   Photo caption (may also be used when resending photos by *file_id*), 0-1024 characters after entities parsing
  parse_mode                    String                                                                             Optional   Mode for parsing entities in the photo caption. See formatting options for more details.
  caption_entities              Array of MessageEntity                                                             Optional   A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse_mode*
  has_spoiler                   Boolean                                                                            Optional   Pass *True* if the photo needs to be covered with a spoiler animation
  disable_notification          Boolean                                                                            Optional   Sends the message silently. Users will receive a notification with no sound.
  protect_content               Boolean                                                                            Optional   Protects the contents of the sent message from forwarding and saving
  reply_to_message_id           Integer                                                                            Optional   If the message is a reply, ID of the original message
  allow_sending_without_reply   Boolean                                                                            Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
  reply_markup                  InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply   Optional   Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendPhoto\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
