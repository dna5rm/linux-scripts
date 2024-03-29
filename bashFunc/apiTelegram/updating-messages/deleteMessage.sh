## deletemessage # Use this method to delete a message, including service messages, with the following limitations:.
# https://core.telegram.org/bots/api#deletemessage

function deleteMessage ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to delete a message, including service messages, with the following limitations:.
	Ref: https://core.telegram.org/bots/api#deletemessage
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to delete a message, including service messages, with
the following limitations:\
- A message can only be deleted if it was sent less than 48 hours ago.\
- Service messages about a supergroup, channel, or forum topic creation
can\'t be deleted.\
- A dice message in a private chat can only be deleted if it was sent
more than 24 hours ago.\
- Bots can delete outgoing messages in private chats, groups, and
supergroups.\
- Bots can delete incoming messages in private chats.\
- Bots granted *can_post_messages* permissions can delete outgoing
messages in channels.\
- If the bot is an administrator of a group, it can delete any message
there.\
- If the bot has *can_delete_messages* permission in a supergroup or a
channel, it can delete any message there.\
Returns *True* on success.
  Parameter    Type                Required   Description
  ------------ ------------------- ---------- ------------------------------------------------------------------------------------------------------------
  chat_id      Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
  message_id   Integer             Yes        Identifier of the message to delete
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/deleteMessage\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
