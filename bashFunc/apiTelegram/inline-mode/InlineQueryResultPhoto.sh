## inlinequeryresultphoto # Represents a link to a photo.
# https://core.telegram.org/bots/api#inlinequeryresultphoto

function InlineQueryResultPhoto ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to a photo.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultphoto
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a link to a photo. By default, this photo will be sent by the
	user with optional caption. Alternatively, you can use
	*input_message_content* to send a message with the specified content
	instead of the photo.
	
	  Field                   Type                     Description
	  ----------------------- ------------------------ -----------------------------------------------------------------------------------------------------------------
	  type                    String                   Type of the result, must be *photo*
	  id                      String                   Unique identifier for this result, 1-64 bytes
	  photo_url               String                   A valid URL of the photo. Photo must be in **JPEG** format. Photo size must not exceed 5MB
	  thumbnail_url           String                   URL of the thumbnail for the photo
	  photo_width             Integer                  *Optional*. Width of the photo
	  photo_height            Integer                  *Optional*. Height of the photo
	  title                   String                   *Optional*. Title for the result
	  description             String                   *Optional*. Short description of the result
	  caption                 String                   *Optional*. Caption of the photo to be sent, 0-1024 characters after entities parsing
	  parse_mode              String                   *Optional*. Mode for parsing entities in the photo caption. See formatting options for more details.
	  caption_entities        Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
	  reply_markup            InlineKeyboardMarkup     *Optional*. Inline keyboard attached to the message
	  input_message_content   InputMessageContent      *Optional*. Content of the message to be sent instead of the photo
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultPhoto" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
