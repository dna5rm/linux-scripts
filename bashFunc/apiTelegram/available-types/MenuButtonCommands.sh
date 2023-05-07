## menubuttoncommands # Represents a menu button, which opens the bot's list of commands.
# https://core.telegram.org/bots/api#menubuttoncommands

function MenuButtonCommands ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a menu button, which opens the bot's list of commands.
	Ref: https://core.telegram.org/bots/api#menubuttoncommands
	---
	Represents a menu button, which opens the bot's list of commands.
	
	  Field   Type     Description
	  ------- -------- ----------------------------------------
	  type    String   Type of the button, must be *commands*
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/MenuButtonCommands" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
