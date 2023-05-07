## keyboardbuttonrequestuser # This object defines the criteria used to request a suitable user.
# https://core.telegram.org/bots/api#keyboardbuttonrequestuser

function KeyboardButtonRequestUser ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object defines the criteria used to request a suitable user.
	Ref: https://core.telegram.org/bots/api#keyboardbuttonrequestuser
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object defines the criteria used to request a suitable user. The
	identifier of the selected user will be shared with the bot when the
	corresponding button is pressed. More about requesting users »
	
	  Field             Type      Description
	  ----------------- --------- ----------------------------------------------------------------------------------------------------------------------------------------------------------
	  request_id        Integer   Signed 32-bit identifier of the request, which will be received back in the UserShared object. Must be unique within the message
	  user_is_bot       Boolean   *Optional*. Pass *True* to request a bot, pass *False* to request a regular user. If not specified, no additional restrictions are applied.
	  user_is_premium   Boolean   *Optional*. Pass *True* to request a premium user, pass *False* to request a non-premium user. If not specified, no additional restrictions are applied.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/KeyboardButtonRequestUser" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
