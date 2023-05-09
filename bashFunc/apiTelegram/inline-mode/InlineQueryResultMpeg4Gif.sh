## inlinequeryresultmpeg4gif # Represents a link to a video animation (H.
# https://core.telegram.org/bots/api#inlinequeryresultmpeg4gif

function InlineQueryResultMpeg4Gif ()
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
	Ref: https://core.telegram.org/bots/api#inlinequeryresultmpeg4gif
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a link to a video animation (H.264/MPEG-4 AVC video without
sound). By default, this animated MPEG-4 file will be sent by the user
with optional caption. Alternatively, you can use
*input_message_content* to send a message with the specified content
instead of the animation.
  Field                   Type                     Description
  ----------------------- ------------------------ ----------------------------------------------------------------------------------------------------------------------------
  type                    String                   Type of the result, must be *mpeg4_gif*
  id                      String                   Unique identifier for this result, 1-64 bytes
  mpeg4_url               String                   A valid URL for the MPEG4 file. File size must not exceed 1MB
  mpeg4_width             Integer                  *Optional*. Video width
  mpeg4_height            Integer                  *Optional*. Video height
  mpeg4_duration          Integer                  *Optional*. Video duration in seconds
  thumbnail_url           String                   URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result
  thumbnail_mime_type     String                   *Optional*. MIME type of the thumbnail, must be one of "image/jpeg", "image/gif", or "video/mp4". Defaults to "image/jpeg"
  title                   String                   *Optional*. Title for the result
  caption                 String                   *Optional*. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing
  parse_mode              String                   *Optional*. Mode for parsing entities in the caption. See formatting options for more details.
  caption_entities        Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
  reply_markup            InlineKeyboardMarkup     *Optional*. Inline keyboard attached to the message
  input_message_content   InputMessageContent      *Optional*. Content of the message to be sent instead of the video animation
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultMpeg4Gif\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
