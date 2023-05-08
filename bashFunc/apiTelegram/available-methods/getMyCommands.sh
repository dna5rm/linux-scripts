## getmycommands # Use this method to get the current list of the bot's commands for the given scope and user language.
# https://core.telegram.org/bots/api#getmycommands

function getMyCommands ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get the current list of the bot's commands for the given scope and user language.
	Ref: https://core.telegram.org/bots/api#getmycommands
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to get the current list of the bot\'s commands for the
given scope and user language. Returns an Array of BotCommand objects.
If commands aren\'t set, an empty list is returned.
  Parameter       Type              Required   Description
  --------------- ----------------- ---------- ------------------------------------------------------------------------------------------
  scope           BotCommandScope   Optional   A JSON-serialized object, describing scope of users. Defaults to BotCommandScopeDefault.
  language_code   String            Optional   A two-letter ISO 639-1 language code or an empty string
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getMyCommands" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
