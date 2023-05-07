## choseninlineresult # Represents a result of an inline query that was chosen by the user and sent to their chat partner.
# https://core.telegram.org/bots/api#choseninlineresult

function ChosenInlineResult ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a result of an inline query that was chosen by the user and sent to their chat partner.
	Ref: https://core.telegram.org/bots/api#choseninlineresult
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a result of an inline query that was chosen by the user and
	sent to their chat partner.
	
	  Field               Type       Description
	  ------------------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  result_id           String     The unique identifier for the result that was chosen
	  from                User       The user that chose the result
	  location            Location   *Optional*. Sender location, only for bots that require user location
	  inline_message_id   String     *Optional*. Identifier of the sent inline message. Available only if there is an inline keyboard attached to the message. Will be also received in callback queries and can be used to edit the message.
	  query               String     The query that was used to obtain the result
	
	**Note:** It is necessary to enable inline feedback via @BotFather in
	order to receive these objects in updates.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChosenInlineResult" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
