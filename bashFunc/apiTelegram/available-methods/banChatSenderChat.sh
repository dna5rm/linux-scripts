## banchatsenderchat # Use this method to ban a channel chat in a supergroup or a channel.
# https://core.telegram.org/bots/api#banchatsenderchat

function banChatSenderChat ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to ban a channel chat in a supergroup or a channel.
	Ref: https://core.telegram.org/bots/api#banchatsenderchat
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to ban a channel chat in a supergroup or a channel.
	Until the chat is unbanned, the owner of the banned chat won't be able
	to send messages on behalf of **any of their channels**. The bot must be
	an administrator in the supergroup or channel for this to work and must
	have the appropriate administrator rights. Returns *True* on success.
	
	  Parameter        Type                Required   Description
	  ---------------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------
	  chat_id          Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  sender_chat_id   Integer             Yes        Unique identifier of the target sender chat
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/banChatSenderChat" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
