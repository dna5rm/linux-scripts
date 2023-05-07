## inlinequeryresultcachedgif # Represents a link to an animated GIF file stored on the Telegram servers.
# https://core.telegram.org/bots/api#inlinequeryresultcachedgif

function InlineQueryResultCachedGif ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to an animated GIF file stored on the Telegram servers.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultcachedgif
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a link to an animated GIF file stored on the Telegram
	servers. By default, this animated GIF file will be sent by the user
	with an optional caption. Alternatively, you can use
	*input_message_content* to send a message with specified content instead
	of the animation.
	
	  Field                   Type                     Description
	  ----------------------- ------------------------ -----------------------------------------------------------------------------------------------------------------
	  type                    String                   Type of the result, must be *gif*
	  id                      String                   Unique identifier for this result, 1-64 bytes
	  gif_file_id             String                   A valid file identifier for the GIF file
	  title                   String                   *Optional*. Title for the result
	  caption                 String                   *Optional*. Caption of the GIF file to be sent, 0-1024 characters after entities parsing
	  parse_mode              String                   *Optional*. Mode for parsing entities in the caption. See formatting options for more details.
	  caption_entities        Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
	  reply_markup            InlineKeyboardMarkup     *Optional*. Inline keyboard attached to the message
	  input_message_content   InputMessageContent      *Optional*. Content of the message to be sent instead of the GIF animation
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultCachedGif" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
