## setchatadministratorcustomtitle # Use this method to set a custom title for an administrator in a supergroup promoted by the bot.
# https://core.telegram.org/bots/api#setchatadministratorcustomtitle

function setChatAdministratorCustomTitle ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to set a custom title for an administrator in a supergroup promoted by the bot.
	Ref: https://core.telegram.org/bots/api#setchatadministratorcustomtitle
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to set a custom title for an administrator in a
supergroup promoted by the bot. Returns *True* on success.
  Parameter      Type                Required   Description
  -------------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------
  chat_id        Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
  user_id        Integer             Yes        Unique identifier of the target user
  custom_title   String              Yes        New custom title for the administrator; 0-16 characters, emoji are not allowed
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setChatAdministratorCustomTitle\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
