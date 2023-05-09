## banchatmember # Use this method to ban a user in a group, a supergroup or a channel.
# https://core.telegram.org/bots/api#banchatmember

function banChatMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to ban a user in a group, a supergroup or a channel.
	Ref: https://core.telegram.org/bots/api#banchatmember
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to ban a user in a group, a supergroup or a channel. In
the case of supergroups and channels, the user will not be able to
return to the chat on their own using invite links, etc., unless
unbanned first. The bot must be an administrator in the chat for this to
work and must have the appropriate administrator rights. Returns *True*
on success.
  Parameter         Type                Required   Description
  ----------------- ------------------- ---------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  chat_id           Integer or String   Yes        Unique identifier for the target group or username of the target supergroup or channel (in the format `@channelusername`)
  user_id           Integer             Yes        Unique identifier of the target user
  until_date        Integer             Optional   Date when the user will be unbanned, unix time. If user is banned for more than 366 days or less than 30 seconds from the current time they are considered to be banned forever. Applied for supergroups and channels only.
  revoke_messages   Boolean             Optional   Pass *True* to delete all messages from the chat for the user that is being removed. If *False*, the user will be able to see messages in the group that were sent before the user was removed. Always *True* for supergroups and channels.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/banChatMember\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
