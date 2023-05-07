## sendmediagroup # Use this method to send a group of photos, videos, documents or audios as an album.
# https://core.telegram.org/bots/api#sendmediagroup

function sendMediaGroup ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send a group of photos, videos, documents or audios as an album.
	Ref: https://core.telegram.org/bots/api#sendmediagroup
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to send a group of photos, videos, documents or audios
	as an album. Documents and audio files can be only grouped in an album
	with messages of the same type. On success, an array of Messages that
	were sent is returned.
	
	  Parameter                     Type                                                                                Required   Description
	  ----------------------------- ----------------------------------------------------------------------------------- ---------- ------------------------------------------------------------------------------------------------------------
	  chat_id                       Integer or String                                                                   Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_thread_id             Integer                                                                             Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
	  media                         Array of InputMediaAudio, InputMediaDocument, InputMediaPhoto and InputMediaVideo   Yes        A JSON-serialized array describing messages to be sent, must include 2-10 items
	  disable_notification          Boolean                                                                             Optional   Sends messages silently. Users will receive a notification with no sound.
	  protect_content               Boolean                                                                             Optional   Protects the contents of the sent messages from forwarding and saving
	  reply_to_message_id           Integer                                                                             Optional   If the messages are a reply, ID of the original message
	  allow_sending_without_reply   Boolean                                                                             Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMediaGroup" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
