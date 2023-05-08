## inlinequeryresultcachedsticker # Represents a link to a sticker stored on the Telegram servers.
# https://core.telegram.org/bots/api#inlinequeryresultcachedsticker

function InlineQueryResultCachedSticker ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a link to a sticker stored on the Telegram servers.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultcachedsticker
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a link to a sticker stored on the Telegram servers. By
default, this sticker will be sent by the user. Alternatively, you can
use *input_message_content* to send a message with the specified content
instead of the sticker.
  Field                   Type                   Description
  ----------------------- ---------------------- ----------------------------------------------------------------------
  type                    String                 Type of the result, must be *sticker*
  id                      String                 Unique identifier for this result, 1-64 bytes
  sticker_file_id         String                 A valid file identifier of the sticker
  reply_markup            InlineKeyboardMarkup   *Optional*. Inline keyboard attached to the message
  input_message_content   InputMessageContent    *Optional*. Content of the message to be sent instead of the sticker
**Note:** This will only work in Telegram versions released after 9
April, 2016 for static stickers and after 06 July, 2019 for animated
stickers. Older clients will ignore them.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultCachedSticker" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
