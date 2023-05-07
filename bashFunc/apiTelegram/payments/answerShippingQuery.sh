## answershippingquery # If you sent an invoice requesting a shipping address and the parameter *is_flexible* was specified, the Bot API will send an Update with a *shipping_query* field to the bot.
# https://core.telegram.org/bots/api#answershippingquery

function answerShippingQuery ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - If you sent an invoice requesting a shipping address and the parameter *is_flexible* was specified, the Bot API will send an Update with a *shipping_query* field to the bot.
	Ref: https://core.telegram.org/bots/api#answershippingquery
	---
	If you sent an invoice requesting a shipping address and the parameter
	*is_flexible* was specified, the Bot API will send an Update with a
	*shipping_query* field to the bot. Use this method to reply to shipping
	queries. On success, *True* is returned.
	
	  Parameter           Type                      Required   Description
	  ------------------- ------------------------- ---------- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  shipping_query_id   String                    Yes        Unique identifier for the query to be answered
	  ok                  Boolean                   Yes        Pass *True* if delivery to the specified address is possible and *False* if there are any problems (for example, if delivery to the specified address is not possible)
	  shipping_options    Array of ShippingOption   Optional   Required if *ok* is *True*. A JSON-serialized array of available shipping options.
	  error_message       String                    Optional   Required if *ok* is *False*. Error message in human readable form that explains why it is impossible to complete the order (e.g. "Sorry, delivery to your desired address is unavailable'). Telegram will display this message to the user.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/answerShippingQuery" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
