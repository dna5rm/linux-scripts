## sentwebappmessage # Describes an inline message sent by a Web App on behalf of a user.
# https://core.telegram.org/bots/api#sentwebappmessage

function SentWebAppMessage ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Describes an inline message sent by a Web App on behalf of a user.
	Ref: https://core.telegram.org/bots/api#sentwebappmessage
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Describes an inline message sent by a Web App on behalf of a user.
	
	  Field               Type     Description
	  ------------------- -------- ---------------------------------------------------------------------------------------------------------------------------
	  inline_message_id   String   *Optional*. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/SentWebAppMessage" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
