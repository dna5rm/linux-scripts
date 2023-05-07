## invoice # This object contains basic information about an invoice.
# https://core.telegram.org/bots/api#invoice

function Invoice ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object contains basic information about an invoice.
	Ref: https://core.telegram.org/bots/api#invoice
	---
	This object contains basic information about an invoice.
	
	  Field             Type      Description
	  ----------------- --------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  title             String    Product name
	  description       String    Product description
	  start_parameter   String    Unique bot deep-linking parameter that can be used to generate this invoice
	  currency          String    Three-letter ISO 4217 currency code
	  total_amount      Integer   Total price in the *smallest units* of the currency (integer, **not** float/double). For example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp* parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/Invoice" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
