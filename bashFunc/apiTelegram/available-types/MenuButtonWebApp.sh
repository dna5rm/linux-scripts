## menubuttonwebapp # Represents a menu button, which launches a Web App.
# https://core.telegram.org/bots/api#menubuttonwebapp

function MenuButtonWebApp ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a menu button, which launches a Web App.
	Ref: https://core.telegram.org/bots/api#menubuttonwebapp
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a menu button, which launches a Web App.
	
	  Field     Type         Description
	  --------- ------------ ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  type      String       Type of the button, must be *web_app*
	  text      String       Text on the button
	  web_app   WebAppInfo   Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method answerWebAppQuery.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/MenuButtonWebApp" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
