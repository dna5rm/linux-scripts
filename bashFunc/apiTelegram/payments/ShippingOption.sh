## shippingoption # This object represents one shipping option.
# https://core.telegram.org/bots/api#shippingoption

function ShippingOption ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents one shipping option.
	Ref: https://core.telegram.org/bots/api#shippingoption
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object represents one shipping option.
	
	  Field    Type                    Description
	  -------- ----------------------- ----------------------------
	  id       String                  Shipping option identifier
	  title    String                  Option title
	  prices   Array of LabeledPrice   List of price portions
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ShippingOption" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
