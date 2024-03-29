## answerprecheckoutquery # Once the user has confirmed their payment and shipping details, the Bot API sends the final confirmation in the form of an Update with the field *pre_checkout_query*.
# https://core.telegram.org/bots/api#answerprecheckoutquery

function answerPreCheckoutQuery ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Once the user has confirmed their payment and shipping details, the Bot API sends the final confirmation in the form of an Update with the field *pre_checkout_query*.
	Ref: https://core.telegram.org/bots/api#answerprecheckoutquery
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Once the user has confirmed their payment and shipping details, the Bot
API sends the final confirmation in the form of an Update with the field
*pre_checkout_query*. Use this method to respond to such pre-checkout
queries. On success, *True* is returned. **Note:** The Bot API must
receive an answer within 10 seconds after the pre-checkout query was
sent.
  Parameter               Type      Required   Description
  ----------------------- --------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  pre_checkout_query_id   String    Yes        Unique identifier for the query to be answered
  ok                      Boolean   Yes        Specify *True* if everything is alright (goods are available, etc.) and the bot is ready to proceed with the order. Use *False* if there are any problems.
  error_message           String    Optional   Required if *ok* is *False*. Error message in human readable form that explains the reason for failure to proceed with the checkout (e.g. \"Sorry, somebody just bought the last of our amazing black T-shirts while you were busy filling out your payment details. Please choose a different color or garment!\"). Telegram will display this message to the user.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/answerPreCheckoutQuery\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
