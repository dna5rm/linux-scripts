## revokechatinvitelink # Use this method to revoke an invite link created by the bot.
# https://core.telegram.org/bots/api#revokechatinvitelink

function revokeChatInviteLink ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to revoke an invite link created by the bot.
	Ref: https://core.telegram.org/bots/api#revokechatinvitelink
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to revoke an invite link created by the bot. If the
	primary link is revoked, a new link is automatically generated. The bot
	must be an administrator in the chat for this to work and must have the
	appropriate administrator rights. Returns the revoked invite link as
	ChatInviteLink object.
	
	  Parameter     Type                Required   Description
	  ------------- ------------------- ---------- -----------------------------------------------------------------------------------------------------------
	  chat_id       Integer or String   Yes        Unique identifier of the target chat or username of the target channel (in the format \`@channelusername\`)
	  invite_link   String              Yes        The invite link to revoke
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/revokeChatInviteLink" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
