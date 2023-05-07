## menubuttondefault # Describes that no specific value for the menu button was set.
# https://core.telegram.org/bots/api#menubuttondefault

function MenuButtonDefault ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Describes that no specific value for the menu button was set.
	Ref: https://core.telegram.org/bots/api#menubuttondefault
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Describes that no specific value for the menu button was set.
	
	  Field   Type     Description
	  ------- -------- ---------------------------------------
	  type    String   Type of the button, must be *default*
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/MenuButtonDefault" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
