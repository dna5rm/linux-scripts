## inputtextmessagecontent # Represents the content of a text message to be sent as the result of an inline query.
# https://core.telegram.org/bots/api#inputtextmessagecontent

function InputTextMessageContent ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the content of a text message to be sent as the result of an inline query.
	Ref: https://core.telegram.org/bots/api#inputtextmessagecontent
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents the content of a text message to be sent as the result of an
	inline query.
	
	  Field                      Type                     Description
	  -------------------------- ------------------------ ------------------------------------------------------------------------------------------------------------------
	  message_text               String                   Text of the message to be sent, 1-4096 characters
	  parse_mode                 String                   *Optional*. Mode for parsing entities in the message text. See formatting options for more details.
	  entities                   Array of MessageEntity   *Optional*. List of special entities that appear in message text, which can be specified instead of *parse_mode*
	  disable_web_page_preview   Boolean                  *Optional*. Disables link previews for links in the sent message
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputTextMessageContent" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
