## pinchatmessage # Use this method to add a message to the list of pinned messages in a chat.
# https://core.telegram.org/bots/api#pinchatmessage

function pinChatMessage ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to add a message to the list of pinned messages in a chat.
	Ref: https://core.telegram.org/bots/api#pinchatmessage
	---
	Use this method to add a message to the list of pinned messages in a
	chat. If the chat is not a private chat, the bot must be an
	administrator in the chat for this to work and must have the
	'can_pin_messages' administrator right in a supergroup or
	'can_edit_messages' administrator right in a channel. Returns *True*
	on success.
	
	  Parameter              Type                Required   Description
	  ---------------------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
	  message_id             Integer             Yes        Identifier of a message to pin
	  disable_notification   Boolean             Optional   Pass *True* if it is not necessary to send a notification to all chat members about the new pinned message. Notifications are always disabled in channels and private chats.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/pinChatMessage" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
