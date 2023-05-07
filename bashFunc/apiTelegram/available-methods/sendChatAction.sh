## sendchataction # Use this method when you need to tell the user that something is happening on the bot's side.
# https://core.telegram.org/bots/api#sendchataction

function sendChatAction ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method when you need to tell the user that something is happening on the bot's side.
	Ref: https://core.telegram.org/bots/api#sendchataction
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method when you need to tell the user that something is
	happening on the bot's side. The status is set for 5 seconds or less
	(when a message arrives from your bot, Telegram clients clear its typing
	status). Returns *True* on success.
	
	> Example: The ImageBot needs some time to process a request and upload
	> the image. Instead of sending a text message along the lines of
	> "Retrieving image, please wait...", the bot may use sendChatAction
	> with *action* = *upload_photo*. The user will see a "sending photo"
	> status for the bot.
	
	We only recommend using this method when a response from the bot will
	take a **noticeable** amount of time to arrive.
	
	  Parameter           Type                Required   Description
	  ------------------- ------------------- ---------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id             Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_thread_id   Integer             Optional   Unique identifier for the target message thread; supergroups only
	  action              String              Yes        Type of action to broadcast. Choose one, depending on what the user is about to receive: *typing* for text messages, *upload_photo* for photos, *record_video* or *upload_video* for videos, *record_voice* or *upload_voice* for voice notes, *upload_document* for general files, *choose_sticker* for stickers, *find_location* for location data, *record_video_note* or *upload_video_note* for video notes.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendChatAction" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
