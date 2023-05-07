## botcommandscopedefault # Represents the default scope of bot commands.
# https://core.telegram.org/bots/api#botcommandscopedefault

function BotCommandScopeDefault ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the default scope of bot commands.
	Ref: https://core.telegram.org/bots/api#botcommandscopedefault
	---
	Represents the default scope of bot commands. Default commands are used
	if no commands with a narrower scope are specified for the user.
	
	  Field   Type     Description
	  ------- -------- -------------------------------
	  type    String   Scope type, must be *default*
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommandScopeDefault" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
