## chatlocation # Represents a location to which a chat is connected.
# https://core.telegram.org/bots/api#chatlocation

function ChatLocation ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a location to which a chat is connected.
	Ref: https://core.telegram.org/bots/api#chatlocation
	---
	Represents a location to which a chat is connected.
	
	  Field      Type       Description
	  ---------- ---------- -------------------------------------------------------------------------------
	  location   Location   The location to which the supergroup is connected. Can't be a live location.
	  address    String     Location address; 1-64 characters, as defined by the chat owner
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatLocation" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
