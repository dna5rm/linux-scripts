## shippingaddress # This object represents a shipping address.
# https://core.telegram.org/bots/api#shippingaddress

function ShippingAddress ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a shipping address.
	Ref: https://core.telegram.org/bots/api#shippingaddress
	---
	This object represents a shipping address.
	
	  Field          Type     Description
	  -------------- -------- --------------------------------------------
	  country_code   String   Two-letter ISO 3166-1 alpha-2 country code
	  state          String   State, if applicable
	  city           String   City
	  street_line1   String   First line for the address
	  street_line2   String   Second line for the address
	  post_code      String   Address post code
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ShippingAddress" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
