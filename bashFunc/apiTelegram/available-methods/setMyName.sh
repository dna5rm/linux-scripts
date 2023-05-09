## setmyname # Use this method to change the bot's name.
# https://core.telegram.org/bots/api#setmyname

function setMyName ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the bot's name.
	Ref: https://core.telegram.org/bots/api#setmyname
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to change the bot\'s name. Returns *True* on success.
  Parameter       Type     Required   Description
  --------------- -------- ---------- ------------------------------------------------------------------------------------------------------------------------------------
  name            String   Optional   New bot name; 0-64 characters. Pass an empty string to remove the dedicated name for the given language.
  language_code   String   Optional   A two-letter ISO 639-1 language code. If empty, the name will be shown to all users for whose language there is no dedicated name.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setMyName\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
