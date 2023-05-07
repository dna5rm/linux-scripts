## getchatmember # Use this method to get information about a member of a chat.
# https://core.telegram.org/bots/api#getchatmember

function getChatMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get information about a member of a chat.
	Ref: https://core.telegram.org/bots/api#getchatmember
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to get information about a member of a chat. The method
	is only guaranteed to work for other users if the bot is an
	administrator in the chat. Returns a ChatMember object on success.
	
	  Parameter   Type                Required   Description
	  ----------- ------------------- ---------- --------------------------------------------------------------------------------------------------------------------------
	  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup or channel (in the format \`@channelusername\`)
	  user_id     Integer             Yes        Unique identifier of the target user
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getChatMember" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
