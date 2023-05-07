## deletemycommands # Use this method to delete the list of the bot's commands for the given scope and user language.
# https://core.telegram.org/bots/api#deletemycommands

function deleteMyCommands ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to delete the list of the bot's commands for the given scope and user language.
	Ref: https://core.telegram.org/bots/api#deletemycommands
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to delete the list of the bot's commands for the given
	scope and user language. After deletion, higher level commands will be
	shown to affected users. Returns *True* on success.
	
	  Parameter       Type              Required   Description
	  --------------- ----------------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
	  scope           BotCommandScope   Optional   A JSON-serialized object, describing scope of users for which the commands are relevant. Defaults to BotCommandScopeDefault.
	  language_code   String            Optional   A two-letter ISO 639-1 language code. If empty, commands will be applied to all users from the given scope, for whose language there are no dedicated commands
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/deleteMyCommands" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
