## senddocument # Use this method to send general files.
# https://core.telegram.org/bots/api#senddocument

function sendDocument ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send general files.
	Ref: https://core.telegram.org/bots/api#senddocument
	---
	Use this method to send general files. On success, the sent Message is
	returned. Bots can currently send files of any type of up to 50 MB in
	size, this limit may be changed in the future.
	
	  Parameter                        Type                                                                               Required   Description
	  -------------------------------- ---------------------------------------------------------------------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                          Integer or String                                                                  Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
	  message_thread_id                Integer                                                                            Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
	  document                         InputFile or String                                                                Yes        File to send. Pass a file_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More information on Sending Files »
	  thumbnail                        InputFile or String                                                                Optional   Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files »
	  caption                          String                                                                             Optional   Document caption (may also be used when resending documents by *file_id*), 0-1024 characters after entities parsing
	  parse_mode                       String                                                                             Optional   Mode for parsing entities in the document caption. See formatting options for more details.
	  caption_entities                 Array of MessageEntity                                                             Optional   A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse_mode*
	  disable_content_type_detection   Boolean                                                                            Optional   Disables automatic server-side content type detection for files uploaded using multipart/form-data
	  disable_notification             Boolean                                                                            Optional   Sends the message silently. Users will receive a notification with no sound.
	  protect_content                  Boolean                                                                            Optional   Protects the contents of the sent message from forwarding and saving
	  reply_to_message_id              Integer                                                                            Optional   If the message is a reply, ID of the original message
	  allow_sending_without_reply      Boolean                                                                            Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
	  reply_markup                     InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply   Optional   Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
