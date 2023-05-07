## deletemessage # Use this method to delete a message, including service messages, with the following limitations:.
# https://core.telegram.org/bots/api#deletemessage

function deleteMessage ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to delete a message, including service messages, with the following limitations:.
	Ref: https://core.telegram.org/bots/api#deletemessage
	---
	Use this method to delete a message, including service messages, with
	the following limitations:
	- A message can only be deleted if it was sent less than 48 hours ago.
	- Service messages about a supergroup, channel, or forum topic creation
	can't be deleted.
	- A dice message in a private chat can only be deleted if it was sent
	more than 24 hours ago.
	- Bots can delete outgoing messages in private chats, groups, and
	supergroups.
	- Bots can delete incoming messages in private chats.
	- Bots granted *can_post_messages* permissions can delete outgoing
	messages in channels.
	- If the bot is an administrator of a group, it can delete any message
	there.
	- If the bot has *can_delete_messages* permission in a supergroup or a
	channel, it can delete any message there.
	Returns *True* on success.
	
	  Parameter    Type                Required   Description
	  ------------ ------------------- ---------- ------------------------------------------------------------------------------------------------------------
	  chat_id      Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
	  message_id   Integer             Yes        Identifier of the message to delete
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/deleteMessage" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
