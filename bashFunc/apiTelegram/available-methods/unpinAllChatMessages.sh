## unpinallchatmessages # Use this method to clear the list of pinned messages in a chat.
# https://core.telegram.org/bots/api#unpinallchatmessages

function unpinAllChatMessages ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to clear the list of pinned messages in a chat.
	Ref: https://core.telegram.org/bots/api#unpinallchatmessages
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to clear the list of pinned messages in a chat. If the
chat is not a private chat, the bot must be an administrator in the chat
for this to work and must have the \'can_pin_messages\' administrator
right in a supergroup or \'can_edit_messages\' administrator right in a
channel. Returns *True* on success.
  Parameter   Type                Required   Description
  ----------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------
  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/unpinAllChatMessages\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
