## approvechatjoinrequest # Use this method to approve a chat join request.
# https://core.telegram.org/bots/api#approvechatjoinrequest

function approveChatJoinRequest ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to approve a chat join request.
	Ref: https://core.telegram.org/bots/api#approvechatjoinrequest
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to approve a chat join request. The bot must be an
	administrator in the chat for this to work and must have the
	*can_invite_users* administrator right. Returns *True* on success.
	
	  Parameter   Type                Required   Description
	  ----------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------
	  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  user_id     Integer             Yes        Unique identifier of the target user
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/approveChatJoinRequest" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
