## banchatmember # Use this method to ban a user in a group, a supergroup or a channel.
# https://core.telegram.org/bots/api#banchatmember

function banChatMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to ban a user in a group, a supergroup or a channel.
	Ref: https://core.telegram.org/bots/api#banchatmember
	---
	Use this method to ban a user in a group, a supergroup or a channel. In
	the case of supergroups and channels, the user will not be able to
	return to the chat on their own using invite links, etc., unless
	unbanned first. The bot must be an administrator in the chat for this to
	work and must have the appropriate administrator rights. Returns *True*
	on success.
	
	  Parameter         Type                Required   Description
	  ----------------- ------------------- ---------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id           Integer or String   Yes        Unique identifier for the target group or username of the target supergroup or channel (in the format `@channelusername`)
	  user_id           Integer             Yes        Unique identifier of the target user
	  until_date        Integer             Optional   Date when the user will be unbanned, unix time. If user is banned for more than 366 days or less than 30 seconds from the current time they are considered to be banned forever. Applied for supergroups and channels only.
	  revoke_messages   Boolean             Optional   Pass *True* to delete all messages from the chat for the user that is being removed. If *False*, the user will be able to see messages in the group that were sent before the user was removed. Always *True* for supergroups and channels.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/banChatMember" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
