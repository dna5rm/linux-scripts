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

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the list of the bot's commands.
	Ref: https://core.telegram.org/bots/api#setmycommands
	---
	Use this method to change the list of the bot's commands. See this
	manual for more details about bot commands. Returns *True* on success.
	
	  Parameter       Type                  Required   Description
	  --------------- --------------------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
	  commands        Array of BotCommand   Yes        A JSON-serialized list of bot commands to be set as the list of the bot's commands. At most 100 commands can be specified.
	  scope           BotCommandScope       Optional   A JSON-serialized object, describing scope of users for which the commands are relevant. Defaults to BotCommandScopeDefault.
	  language_code   String                Optional   A two-letter ISO 639-1 language code. If empty, commands will be applied to all users from the given scope, for whose language there are no dedicated commands
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setMyCommands" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
