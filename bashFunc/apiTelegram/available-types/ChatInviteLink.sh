## chatinvitelink # Represents an invite link for a chat.
# https://core.telegram.org/bots/api#chatinvitelink

function ChatInviteLink ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "$(grep -E "+{*}+" <<<${1:-{\}} 2> /dev/null)" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an invite link for a chat.
	Ref: https://core.telegram.org/bots/api#chatinvitelink
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents an invite link for a chat.
	
	  Field                        Type      Description
	  ---------------------------- --------- ---------------------------------------------------------------------------------------------------------------------------------------------
	  invite_link                  String    The invite link. If the link was created by another chat administrator, then the second part of the link will be replaced with "...".
	  creator                      User      Creator of the link
	  creates_join_request         Boolean   *True*, if users joining the chat via the link need to be approved by chat administrators
	  is_primary                   Boolean   *True*, if the link is primary
	  is_revoked                   Boolean   *True*, if the link is revoked
	  name                         String    *Optional*. Invite link name
	  expire_date                  Integer   *Optional*. Point in time (Unix timestamp) when the link will expire or has been expired
	  member_limit                 Integer   *Optional*. The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999
	  pending_join_request_count   Integer   *Optional*. Number of pending join requests created using this link
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatInviteLink" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
