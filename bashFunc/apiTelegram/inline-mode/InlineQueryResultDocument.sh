## inlinequeryresultdocument # Represents a link to a file.
# https://core.telegram.org/bots/api#inlinequeryresultdocument

function InlineQueryResultDocument ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to a file.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultdocument
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a link to a file. By default, this file will be sent by the
user with an optional caption. Alternatively, you can use
*input_message_content* to send a message with the specified content
instead of the file. Currently, only **.PDF** and **.ZIP** files can be
sent using this method.
  Field                   Type                     Description
  ----------------------- ------------------------ -----------------------------------------------------------------------------------------------------------------
  type                    String                   Type of the result, must be *document*
  id                      String                   Unique identifier for this result, 1-64 bytes
  title                   String                   Title for the result
  caption                 String                   *Optional*. Caption of the document to be sent, 0-1024 characters after entities parsing
  parse_mode              String                   *Optional*. Mode for parsing entities in the document caption. See formatting options for more details.
  caption_entities        Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
  document_url            String                   A valid URL for the file
  mime_type               String                   MIME type of the content of the file, either "application/pdf" or "application/zip"
  description             String                   *Optional*. Short description of the result
  reply_markup            InlineKeyboardMarkup     *Optional*. Inline keyboard attached to the message
  input_message_content   InputMessageContent      *Optional*. Content of the message to be sent instead of the file
  thumbnail_url           String                   *Optional*. URL of the thumbnail (JPEG only) for the file
  thumbnail_width         Integer                  *Optional*. Thumbnail width
  thumbnail_height        Integer                  *Optional*. Thumbnail height
**Note:** This will only work in Telegram versions released after 9
April, 2016. Older clients will ignore them.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultDocument" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
