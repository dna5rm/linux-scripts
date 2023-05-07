## keyboardbuttonpolltype # This object represents type of a poll, which is allowed to be created and sent when the corresponding button is pressed.
# https://core.telegram.org/bots/api#keyboardbuttonpolltype

function KeyboardButtonPollType ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents type of a poll, which is allowed to be created and sent when the corresponding button is pressed.
	Ref: https://core.telegram.org/bots/api#keyboardbuttonpolltype
	---
	This object represents type of a poll, which is allowed to be created
	and sent when the corresponding button is pressed.
	
	  Field   Type     Description
	  ------- -------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  type    String   *Optional*. If *quiz* is passed, the user will be allowed to create only polls in the quiz mode. If *regular* is passed, only regular polls will be allowed. Otherwise, the user will be allowed to create a poll of any type.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/KeyboardButtonPollType" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
