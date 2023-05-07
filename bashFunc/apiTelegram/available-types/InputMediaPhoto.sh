## inputmediaphoto # Represents a photo to be sent.
# https://core.telegram.org/bots/api#inputmediaphoto

function InputMediaPhoto ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a photo to be sent.
	Ref: https://core.telegram.org/bots/api#inputmediaphoto
	---
	Represents a photo to be sent.
	
	  Field              Type                     Description
	  ------------------ ------------------------ --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  type               String                   Type of the result, must be *photo*
	  media              String                   File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files »
	  caption            String                   *Optional*. Caption of the photo to be sent, 0-1024 characters after entities parsing
	  parse_mode         String                   *Optional*. Mode for parsing entities in the photo caption. See formatting options for more details.
	  caption_entities   Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
	  has_spoiler        Boolean                  *Optional*. Pass *True* if the photo needs to be covered with a spoiler animation
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputMediaPhoto" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
