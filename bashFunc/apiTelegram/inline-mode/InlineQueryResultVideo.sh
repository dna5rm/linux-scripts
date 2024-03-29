## inlinequeryresultvideo # Represents a link to a page containing an embedded video player or a video file.
# https://core.telegram.org/bots/api#inlinequeryresultvideo

function InlineQueryResultVideo ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to a page containing an embedded video player or a video file.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultvideo
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a link to a page containing an embedded video player or a
video file. By default, this video file will be sent by the user with an
optional caption. Alternatively, you can use *input_message_content* to
send a message with the specified content instead of the video.
> If an InlineQueryResultVideo message contains an embedded video (e.g.,
> YouTube), you **must** replace its content using
> *input_message_content*.
  Field                   Type                     Description
  ----------------------- ------------------------ --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  type                    String                   Type of the result, must be *video*
  id                      String                   Unique identifier for this result, 1-64 bytes
  video_url               String                   A valid URL for the embedded video player or video file
  mime_type               String                   MIME type of the content of the video URL, "text/html" or "video/mp4"
  thumbnail_url           String                   URL of the thumbnail (JPEG only) for the video
  title                   String                   Title for the result
  caption                 String                   *Optional*. Caption of the video to be sent, 0-1024 characters after entities parsing
  parse_mode              String                   *Optional*. Mode for parsing entities in the video caption. See formatting options for more details.
  caption_entities        Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
  video_width             Integer                  *Optional*. Video width
  video_height            Integer                  *Optional*. Video height
  video_duration          Integer                  *Optional*. Video duration in seconds
  description             String                   *Optional*. Short description of the result
  reply_markup            InlineKeyboardMarkup     *Optional*. Inline keyboard attached to the message
  input_message_content   InputMessageContent      *Optional*. Content of the message to be sent instead of the video. This field is **required** if InlineQueryResultVideo is used to send an HTML-page as a result (e.g., a YouTube video).
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultVideo\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
