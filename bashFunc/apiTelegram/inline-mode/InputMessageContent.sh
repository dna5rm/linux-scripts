## inputmessagecontent # This object represents the content of a message to be sent as a result of an inline query.
# https://core.telegram.org/bots/api#inputmessagecontent

function InputMessageContent ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents the content of a message to be sent as a result of an inline query.
	Ref: https://core.telegram.org/bots/api#inputmessagecontent
	---
	This object represents the content of a message to be sent as a result
	of an inline query. Telegram clients currently support the following 5
	types:
	
	-   InputTextMessageContent
	-   InputLocationMessageContent
	-   InputVenueMessageContent
	-   InputContactMessageContent
	-   InputInvoiceMessageContent
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputMessageContent" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
