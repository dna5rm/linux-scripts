## getchatmenubutton # Use this method to get the current value of the bot's menu button in a private chat, or the default menu button.
# https://core.telegram.org/bots/api#getchatmenubutton

function getChatMenuButton ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get the current value of the bot's menu button in a private chat, or the default menu button.
	Ref: https://core.telegram.org/bots/api#getchatmenubutton
	---
	Use this method to get the current value of the bot's menu button in a
	private chat, or the default menu button. Returns MenuButton on success.
	
	  Parameter   Type      Required   Description
	  ----------- --------- ---------- --------------------------------------------------------------------------------------------------------------
	  chat_id     Integer   Optional   Unique identifier for the target private chat. If not specified, default bot's menu button will be returned
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getChatMenuButton" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
