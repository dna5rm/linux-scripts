## inlinequeryresultcontact # Represents a contact with a phone number.
# https://core.telegram.org/bots/api#inlinequeryresultcontact

function InlineQueryResultContact ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a contact with a phone number.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultcontact
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a contact with a phone number. By default, this contact will
	be sent by the user. Alternatively, you can use *input_message_content*
	to send a message with the specified content instead of the contact.
	
	  Field                   Type                   Description
	  ----------------------- ---------------------- ------------------------------------------------------------------------------------
	  type                    String                 Type of the result, must be *contact*
	  id                      String                 Unique identifier for this result, 1-64 Bytes
	  phone_number            String                 Contact's phone number
	  first_name              String                 Contact's first name
	  last_name               String                 *Optional*. Contact's last name
	  vcard                   String                 *Optional*. Additional data about the contact in the form of a vCard, 0-2048 bytes
	  reply_markup            InlineKeyboardMarkup   *Optional*. Inline keyboard attached to the message
	  input_message_content   InputMessageContent    *Optional*. Content of the message to be sent instead of the contact
	  thumbnail_url           String                 *Optional*. Url of the thumbnail for the result
	  thumbnail_width         Integer                *Optional*. Thumbnail width
	  thumbnail_height        Integer                *Optional*. Thumbnail height
	
	**Note:** This will only work in Telegram versions released after 9
	April, 2016. Older clients will ignore them.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultContact" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
