## menubutton # This object describes the bot's menu button in a private chat.
# https://core.telegram.org/bots/api#menubutton

function MenuButton ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object describes the bot's menu button in a private chat.
	Ref: https://core.telegram.org/bots/api#menubutton
	---
	This object describes the bot's menu button in a private chat. It
	should be one of
	
	-   MenuButtonCommands
	-   MenuButtonWebApp
	-   MenuButtonDefault
	
	If a menu button other than MenuButtonDefault is set for a private chat,
	then it is applied in the chat. Otherwise the default menu button is
	applied. By default, the menu button opens the list of bot commands.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/MenuButton" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
