## setmycommands # Use this method to change the list of the bot's commands.
# https://core.telegram.org/bots/api#setmycommands

function setMyCommands ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the list of the bot's commands.
	Ref: https://core.telegram.org/bots/api#setmycommands
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to change the list of the bot\'s commands. See this
manual for more details about bot commands. Returns *True* on success.
  Parameter       Type                  Required   Description
  --------------- --------------------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  commands        Array of BotCommand   Yes        A JSON-serialized list of bot commands to be set as the list of the bot\'s commands. At most 100 commands can be specified.
  scope           BotCommandScope       Optional   A JSON-serialized object, describing scope of users for which the commands are relevant. Defaults to BotCommandScopeDefault.
  language_code   String                Optional   A two-letter ISO 639-1 language code. If empty, commands will be applied to all users from the given scope, for whose language there are no dedicated commands
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setMyCommands\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
