## inlinequeryresultarticle # Represents a link to an article or web page.
# https://core.telegram.org/bots/api#inlinequeryresultarticle

function InlineQueryResultArticle ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to an article or web page.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultarticle
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a link to an article or web page.
  Field                   Type                   Description
  ----------------------- ---------------------- -------------------------------------------------------------------------------
  type                    String                 Type of the result, must be *article*
  id                      String                 Unique identifier for this result, 1-64 Bytes
  title                   String                 Title of the result
  input_message_content   InputMessageContent    Content of the message to be sent
  reply_markup            InlineKeyboardMarkup   *Optional*. Inline keyboard attached to the message
  url                     String                 *Optional*. URL of the result
  hide_url                Boolean                *Optional*. Pass *True* if you don\'t want the URL to be shown in the message
  description             String                 *Optional*. Short description of the result
  thumbnail_url           String                 *Optional*. Url of the thumbnail for the result
  thumbnail_width         Integer                *Optional*. Thumbnail width
  thumbnail_height        Integer                *Optional*. Thumbnail height
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultArticle\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
