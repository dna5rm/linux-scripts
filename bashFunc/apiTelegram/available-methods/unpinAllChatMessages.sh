## unpinallchatmessages # Use this method to clear the list of pinned messages in a chat.
# https://core.telegram.org/bots/api#unpinallchatmessages

function unpinAllChatMessages ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to clear the list of pinned messages in a chat.
	Ref: https://core.telegram.org/bots/api#unpinallchatmessages
	---
	Use this method to clear the list of pinned messages in a chat. If the
	chat is not a private chat, the bot must be an administrator in the chat
	for this to work and must have the 'can_pin_messages' administrator
	right in a supergroup or 'can_edit_messages' administrator right in a
	channel. Returns *True* on success.
	
	  Parameter   Type                Required   Description
	  ----------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------
	  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/unpinAllChatMessages" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
