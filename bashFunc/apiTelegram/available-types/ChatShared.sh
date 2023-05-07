## chatshared # This object contains information about the chat whose identifier was shared with the bot using a KeyboardButtonRequestChat button.
# https://core.telegram.org/bots/api#chatshared

function ChatShared ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object contains information about the chat whose identifier was shared with the bot using a KeyboardButtonRequestChat button.
	Ref: https://core.telegram.org/bots/api#chatshared
	---
	This object contains information about the chat whose identifier was
	shared with the bot using a KeyboardButtonRequestChat button.
	
	  Field        Type      Description
	  ------------ --------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  request_id   Integer   Identifier of the request
	  chat_id      Integer   Identifier of the shared chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot may not have access to the chat and could be unable to use this identifier, unless the chat is already known to the bot by some other means.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatShared" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
