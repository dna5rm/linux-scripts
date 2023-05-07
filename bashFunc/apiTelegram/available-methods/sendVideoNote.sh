## sendvideonote # As of v.
# https://core.telegram.org/bots/api#sendvideonote

function sendVideoNote ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - As of v.
	Ref: https://core.telegram.org/bots/api#sendvideonote
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	As of v.4.0, Telegram clients support rounded square MPEG4 videos of up
	to 1 minute long. Use this method to send video messages. On success,
	the sent Message is returned.
	
	  Parameter                     Type                                                                               Required   Description
	  ----------------------------- ---------------------------------------------------------------------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                       Integer or String                                                                  Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_thread_id             Integer                                                                            Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
	  video_note                    InputFile or String                                                                Yes        Video note to send. Pass a file_id as String to send a video note that exists on the Telegram servers (recommended) or upload a new video using multipart/form-data. More information on Sending Files ». Sending video notes by a URL is currently unsupported
	  duration                      Integer                                                                            Optional   Duration of sent video in seconds
	  length                        Integer                                                                            Optional   Video width and height, i.e. diameter of the video message
	  thumbnail                     InputFile or String                                                                Optional   Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files »
	  disable_notification          Boolean                                                                            Optional   Sends the message silently. Users will receive a notification with no sound.
	  protect_content               Boolean                                                                            Optional   Protects the contents of the sent message from forwarding and saving
	  reply_to_message_id           Integer                                                                            Optional   If the message is a reply, ID of the original message
	  allow_sending_without_reply   Boolean                                                                            Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
	  reply_markup                  InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply   Optional   Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendVideoNote" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
