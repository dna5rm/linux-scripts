## stopmessagelivelocation # Use this method to stop updating a live location message before *live_period* expires.
# https://core.telegram.org/bots/api#stopmessagelivelocation

function stopMessageLiveLocation ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to stop updating a live location message before *live_period* expires.
	Ref: https://core.telegram.org/bots/api#stopmessagelivelocation
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to stop updating a live location message before
	*live_period* expires. On success, if the message is not an inline
	message, the edited Message is returned, otherwise *True* is returned.
	
	  Parameter           Type                   Required   Description
	  ------------------- ---------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id             Integer or String      Optional   Required if *inline_message_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_id          Integer                Optional   Required if *inline_message_id* is not specified. Identifier of the message with live location to stop
	  inline_message_id   String                 Optional   Required if *chat_id* and *message_id* are not specified. Identifier of the inline message
	  reply_markup        InlineKeyboardMarkup   Optional   A JSON-serialized object for a new inline keyboard.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/stopMessageLiveLocation" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
