## answerwebappquery # Use this method to set the result of an interaction with a Web App and send a corresponding message on behalf of the user to the chat from which the query originated.
# https://core.telegram.org/bots/api#answerwebappquery

function answerWebAppQuery ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to set the result of an interaction with a Web App and send a corresponding message on behalf of the user to the chat from which the query originated.
	Ref: https://core.telegram.org/bots/api#answerwebappquery
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to set the result of an interaction with a Web App and
	send a corresponding message on behalf of the user to the chat from
	which the query originated. On success, a SentWebAppMessage object is
	returned.
	
	  Parameter          Type                Required   Description
	  ------------------ ------------------- ---------- ------------------------------------------------------------
	  web_app_query_id   String              Yes        Unique identifier for the query to be answered
	  result             InlineQueryResult   Yes        A JSON-serialized object describing the message to be sent
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/answerWebAppQuery" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
