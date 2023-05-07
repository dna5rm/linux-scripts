## chatmemberleft # Represents a chat member that isn't currently a member of the chat, but may join it themselves.
# https://core.telegram.org/bots/api#chatmemberleft

function ChatMemberLeft ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a chat member that isn't currently a member of the chat, but may join it themselves.
	Ref: https://core.telegram.org/bots/api#chatmemberleft
	---
	Represents a chat member that isn't currently a member of the chat, but
	may join it themselves.
	
	  Field    Type     Description
	  -------- -------- -------------------------------------------------
	  status   String   The member's status in the chat, always "left"
	  user     User     Information about the user
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMemberLeft" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
