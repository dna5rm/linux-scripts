## inlinequeryresultcacheddocument # Represents a link to a file stored on the Telegram servers.
# https://core.telegram.org/bots/api#inlinequeryresultcacheddocument

function InlineQueryResultCachedDocument ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to a file stored on the Telegram servers.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultcacheddocument
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a link to a file stored on the Telegram servers. By default,
this file will be sent by the user with an optional caption.
Alternatively, you can use *input_message_content* to send a message
with the specified content instead of the file.
  Field                   Type                     Description
  ----------------------- ------------------------ -----------------------------------------------------------------------------------------------------------------
  type                    String                   Type of the result, must be *document*
  id                      String                   Unique identifier for this result, 1-64 bytes
  title                   String                   Title for the result
  document_file_id        String                   A valid file identifier for the file
  description             String                   *Optional*. Short description of the result
  caption                 String                   *Optional*. Caption of the document to be sent, 0-1024 characters after entities parsing
  parse_mode              String                   *Optional*. Mode for parsing entities in the document caption. See formatting options for more details.
  caption_entities        Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
  reply_markup            InlineKeyboardMarkup     *Optional*. Inline keyboard attached to the message
  input_message_content   InputMessageContent      *Optional*. Content of the message to be sent instead of the file
**Note:** This will only work in Telegram versions released after 9
April, 2016. Older clients will ignore them.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultCachedDocument\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
