## createchatinvitelink # Use this method to create an additional invite link for a chat.
# https://core.telegram.org/bots/api#createchatinvitelink

function createChatInviteLink ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to create an additional invite link for a chat.
	Ref: https://core.telegram.org/bots/api#createchatinvitelink
	---
	Use this method to create an additional invite link for a chat. The bot
	must be an administrator in the chat for this to work and must have the
	appropriate administrator rights. The link can be revoked using the
	method revokeChatInviteLink. Returns the new invite link as
	ChatInviteLink object.
	
	  Parameter              Type                Required   Description
	  ---------------------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
	  name                   String              Optional   Invite link name; 0-32 characters
	  expire_date            Integer             Optional   Point in time (Unix timestamp) when the link will expire
	  member_limit           Integer             Optional   The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
	  creates_join_request   Boolean             Optional   *True*, if users joining the chat via the link need to be approved by chat administrators. If *True*, *member_limit* can't be specified
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/createChatInviteLink" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
