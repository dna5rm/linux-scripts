## orderinfo # This object represents information about an order.
# https://core.telegram.org/bots/api#orderinfo

function OrderInfo ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents information about an order.
	Ref: https://core.telegram.org/bots/api#orderinfo
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents information about an order.
  Field              Type              Description
  ------------------ ----------------- -----------------------------------
  name               String            *Optional*. User name
  phone_number       String            *Optional*. User\'s phone number
  email              String            *Optional*. User email
  shipping_address   ShippingAddress   *Optional*. User shipping address
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/OrderInfo" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
