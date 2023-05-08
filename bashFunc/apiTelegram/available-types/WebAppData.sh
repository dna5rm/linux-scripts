## webappdata # Describes data sent from a Web App to the bot.
# https://core.telegram.org/bots/api#webappdata

function WebAppData ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Describes data sent from a Web App to the bot.
	Ref: https://core.telegram.org/bots/api#webappdata
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Describes data sent from a Web App to the bot.
  Field         Type     Description
  ------------- -------- --------------------------------------------------------------------------------------------------------------------------------------------
  data          String   The data. Be aware that a bad client can send arbitrary data in this field.
  button_text   String   Text of the *web_app* keyboard button from which the Web App was opened. Be aware that a bad client can send arbitrary data in this field.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/WebAppData" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
