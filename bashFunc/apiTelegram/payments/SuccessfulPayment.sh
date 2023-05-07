## successfulpayment # This object contains basic information about a successful payment.
# https://core.telegram.org/bots/api#successfulpayment

function SuccessfulPayment ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object contains basic information about a successful payment.
	Ref: https://core.telegram.org/bots/api#successfulpayment
	---
	This object contains basic information about a successful payment.
	
	  Field                        Type        Description
	  ---------------------------- ----------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  currency                     String      Three-letter ISO 4217 currency code
	  total_amount                 Integer     Total price in the *smallest units* of the currency (integer, **not** float/double). For example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp* parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).
	  invoice_payload              String      Bot specified invoice payload
	  shipping_option_id           String      *Optional*. Identifier of the shipping option chosen by the user
	  order_info                   OrderInfo   *Optional*. Order information provided by the user
	  telegram_payment_charge_id   String      Telegram payment identifier
	  provider_payment_charge_id   String      Provider payment identifier
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/SuccessfulPayment" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
