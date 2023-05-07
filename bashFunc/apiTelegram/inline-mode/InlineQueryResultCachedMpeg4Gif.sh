## inlinequeryresultcachedmpeg4gif # Represents a link to a video animation (H.
# https://core.telegram.org/bots/api#inlinequeryresultcachedmpeg4gif

function InlineQueryResultCachedMpeg4Gif ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to a video animation (H.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultcachedmpeg4gif
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a link to a video animation (H.264/MPEG-4 AVC video without
	sound) stored on the Telegram servers. By default, this animated MPEG-4
	file will be sent by the user with an optional caption. Alternatively,
	you can use *input_message_content* to send a message with the specified
	content instead of the animation.
	
	  Field                   Type                     Description
	  ----------------------- ------------------------ -----------------------------------------------------------------------------------------------------------------
	  type                    String                   Type of the result, must be *mpeg4_gif*
	  id                      String                   Unique identifier for this result, 1-64 bytes
	  mpeg4_file_id           String                   A valid file identifier for the MPEG4 file
	  title                   String                   *Optional*. Title for the result
	  caption                 String                   *Optional*. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
	  parse_mode              String                   *Optional*. Mode for parsing entities in the caption. See formatting options for more details.
	  caption_entities        Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
	  reply_markup            InlineKeyboardMarkup     *Optional*. Inline keyboard attached to the message
	  input_message_content   InputMessageContent      *Optional*. Content of the message to be sent instead of the video animation
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultCachedMpeg4Gif" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
