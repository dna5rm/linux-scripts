## shippingquery # This object contains information about an incoming shipping query.
# https://core.telegram.org/bots/api#shippingquery

function ShippingQuery ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object contains information about an incoming shipping query.
	Ref: https://core.telegram.org/bots/api#shippingquery
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object contains information about an incoming shipping query.
	
	  Field              Type              Description
	  ------------------ ----------------- ---------------------------------
	  id                 String            Unique query identifier
	  from               User              User who sent the query
	  invoice_payload    String            Bot specified invoice payload
	  shipping_address   ShippingAddress   User specified shipping address
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ShippingQuery" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
