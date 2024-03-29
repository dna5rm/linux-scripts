## setmydescription # Use this method to change the bot's description, which is shown in the chat with the bot if the chat is empty.
# https://core.telegram.org/bots/api#setmydescription

function setMyDescription ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the bot's description, which is shown in the chat with the bot if the chat is empty.
	Ref: https://core.telegram.org/bots/api#setmydescription
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to change the bot\'s description, which is shown in the
chat with the bot if the chat is empty. Returns *True* on success.
  Parameter       Type     Required   Description
  --------------- -------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------
  description     String   Optional   New bot description; 0-512 characters. Pass an empty string to remove the dedicated description for the given language.
  language_code   String   Optional   A two-letter ISO 639-1 language code. If empty, the description will be applied to all users for whose language there is no dedicated description.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setMyDescription\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
