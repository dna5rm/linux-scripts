## exportchatinvitelink # Use this method to generate a new primary invite link for a chat; any previously generated primary link is revoked.
# https://core.telegram.org/bots/api#exportchatinvitelink

function exportChatInviteLink ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to generate a new primary invite link for a chat; any previously generated primary link is revoked.
	Ref: https://core.telegram.org/bots/api#exportchatinvitelink
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to generate a new primary invite link for a chat; any
previously generated primary link is revoked. The bot must be an
administrator in the chat for this to work and must have the appropriate
administrator rights. Returns the new invite link as *String* on
success.
  Parameter   Type                Required   Description
  ----------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------
  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
> Note: Each administrator in a chat generates their own invite links.
> Bots can\'t use invite links generated by other administrators. If you
> want your bot to work with invite links, it will need to generate its
> own link using exportChatInviteLink or by calling the getChat method.
> If your bot needs to generate a new primary invite link replacing its
> previous one, use exportChatInviteLink again.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/exportChatInviteLink\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
