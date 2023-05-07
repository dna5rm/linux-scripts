## messageid # This object represents a unique message identifier.
# https://core.telegram.org/bots/api#messageid

function MessageId ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a unique message identifier.
	Ref: https://core.telegram.org/bots/api#messageid
	---
	This object represents a unique message identifier.
	
	  Field        Type      Description
	  ------------ --------- ---------------------------
	  message_id   Integer   Unique message identifier
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/MessageId" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
