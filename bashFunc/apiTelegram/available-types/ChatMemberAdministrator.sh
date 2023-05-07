## chatmemberadministrator # Represents a chat member that has some additional privileges.
# https://core.telegram.org/bots/api#chatmemberadministrator

function ChatMemberAdministrator ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a chat member that has some additional privileges.
	Ref: https://core.telegram.org/bots/api#chatmemberadministrator
	---
	Represents a chat member that has some additional privileges.
	
	  Field                    Type      Description
	  ------------------------ --------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  status                   String    The member's status in the chat, always "administrator"
	  user                     User      Information about the user
	  can_be_edited            Boolean   *True*, if the bot is allowed to edit administrator privileges of that user
	  is_anonymous             Boolean   *True*, if the user's presence in the chat is hidden
	  can_manage_chat          Boolean   *True*, if the administrator can access the chat event log, chat statistics, message statistics in channels, see channel members, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
	  can_delete_messages      Boolean   *True*, if the administrator can delete messages of other users
	  can_manage_video_chats   Boolean   *True*, if the administrator can manage video chats
	  can_restrict_members     Boolean   *True*, if the administrator can restrict, ban or unban chat members
	  can_promote_members      Boolean   *True*, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)
	  can_change_info          Boolean   *True*, if the user is allowed to change the chat title, photo and other settings
	  can_invite_users         Boolean   *True*, if the user is allowed to invite new users to the chat
	  can_post_messages        Boolean   *Optional*. *True*, if the administrator can post in the channel; channels only
	  can_edit_messages        Boolean   *Optional*. *True*, if the administrator can edit messages of other users and can pin messages; channels only
	  can_pin_messages         Boolean   *Optional*. *True*, if the user is allowed to pin messages; groups and supergroups only
	  can_manage_topics        Boolean   *Optional*. *True*, if the user is allowed to create, rename, close, and reopen forum topics; supergroups only
	  custom_title             String    *Optional*. Custom title for this user
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMemberAdministrator" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
