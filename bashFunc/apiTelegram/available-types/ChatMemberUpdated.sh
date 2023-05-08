## chatmemberupdated # This object represents changes in the status of a chat member.
# https://core.telegram.org/bots/api#chatmemberupdated

function ChatMemberUpdated ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents changes in the status of a chat member.
	Ref: https://core.telegram.org/bots/api#chatmemberupdated
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents changes in the status of a chat member.
  Field                         Type             Description
  ----------------------------- ---------------- --------------------------------------------------------------------------------------------------------------------
  chat                          Chat             Chat the user belongs to
  from                          User             Performer of the action, which resulted in the change
  date                          Integer          Date the change was done in Unix time
  old_chat_member               ChatMember       Previous information about the chat member
  new_chat_member               ChatMember       New information about the chat member
  invite_link                   ChatInviteLink   *Optional*. Chat invite link, which was used by the user to join the chat; for joining by invite link events only.
  via_chat_folder_invite_link   Boolean          *Optional*. True, if the user joined the chat via a chat folder invite link
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMemberUpdated" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
