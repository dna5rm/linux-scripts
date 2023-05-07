## inlinequeryresultcachedaudio # Represents a link to an MP3 audio file stored on the Telegram servers.
# https://core.telegram.org/bots/api#inlinequeryresultcachedaudio

function InlineQueryResultCachedAudio ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to an MP3 audio file stored on the Telegram servers.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultcachedaudio
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a link to an MP3 audio file stored on the Telegram servers.
	By default, this audio file will be sent by the user. Alternatively, you
	can use *input_message_content* to send a message with the specified
	content instead of the audio.
	
	  Field                   Type                     Description
	  ----------------------- ------------------------ -----------------------------------------------------------------------------------------------------------------
	  type                    String                   Type of the result, must be *audio*
	  id                      String                   Unique identifier for this result, 1-64 bytes
	  audio_file_id           String                   A valid file identifier for the audio file
	  caption                 String                   *Optional*. Caption, 0-1024 characters after entities parsing
	  parse_mode              String                   *Optional*. Mode for parsing entities in the audio caption. See formatting options for more details.
	  caption_entities        Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
	  reply_markup            InlineKeyboardMarkup     *Optional*. Inline keyboard attached to the message
	  input_message_content   InputMessageContent      *Optional*. Content of the message to be sent instead of the audio
	
	**Note:** This will only work in Telegram versions released after 9
	April, 2016. Older clients will ignore them.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultCachedAudio" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
