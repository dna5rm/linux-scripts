## inlinekeyboardmarkup # This object represents an inline keyboard that appears right next to the message it belongs to.
# https://core.telegram.org/bots/api#inlinekeyboardmarkup

function InlineKeyboardMarkup ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an inline keyboard that appears right next to the message it belongs to.
	Ref: https://core.telegram.org/bots/api#inlinekeyboardmarkup
	---
	This object represents an inline keyboard that appears right next to the
	message it belongs to.
	
	  Field             Type                                     Description
	  ----------------- ---------------------------------------- ------------------------------------------------------------------------------------
	  inline_keyboard   Array of Array of InlineKeyboardButton   Array of button rows, each represented by an Array of InlineKeyboardButton objects
	
	**Note:** This will only work in Telegram versions released after 9
	April, 2016. Older clients will display *unsupported message*.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineKeyboardMarkup" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
