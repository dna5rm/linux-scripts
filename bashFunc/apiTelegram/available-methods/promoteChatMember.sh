## promotechatmember # Use this method to promote or demote a user in a supergroup or a channel.
# https://core.telegram.org/bots/api#promotechatmember

function promoteChatMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to promote or demote a user in a supergroup or a channel.
	Ref: https://core.telegram.org/bots/api#promotechatmember
	---
	Use this method to promote or demote a user in a supergroup or a
	channel. The bot must be an administrator in the chat for this to work
	and must have the appropriate administrator rights. Pass *False* for all
	boolean parameters to demote a user. Returns *True* on success.
	
	  Parameter                Type                Required   Description
	  ------------------------ ------------------- ---------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                  Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
	  user_id                  Integer             Yes        Unique identifier of the target user
	  is_anonymous             Boolean             Optional   Pass *True* if the administrator's presence in the chat is hidden
	  can_manage_chat          Boolean             Optional   Pass *True* if the administrator can access the chat event log, chat statistics, message statistics in channels, see channel members, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
	  can_post_messages        Boolean             Optional   Pass *True* if the administrator can create channel posts, channels only
	  can_edit_messages        Boolean             Optional   Pass *True* if the administrator can edit messages of other users and can pin messages, channels only
	  can_delete_messages      Boolean             Optional   Pass *True* if the administrator can delete messages of other users
	  can_manage_video_chats   Boolean             Optional   Pass *True* if the administrator can manage video chats
	  can_restrict_members     Boolean             Optional   Pass *True* if the administrator can restrict, ban or unban chat members
	  can_promote_members      Boolean             Optional   Pass *True* if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by him)
	  can_change_info          Boolean             Optional   Pass *True* if the administrator can change chat title, photo and other settings
	  can_invite_users         Boolean             Optional   Pass *True* if the administrator can invite new users to the chat
	  can_pin_messages         Boolean             Optional   Pass *True* if the administrator can pin messages, supergroups only
	  can_manage_topics        Boolean             Optional   Pass *True* if the user is allowed to create, rename, close, and reopen forum topics, supergroups only
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/promoteChatMember" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
