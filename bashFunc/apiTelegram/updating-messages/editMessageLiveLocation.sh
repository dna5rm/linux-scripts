## editmessagelivelocation # Use this method to edit live location messages.
# https://core.telegram.org/bots/api#editmessagelivelocation

function editMessageLiveLocation ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to edit live location messages.
	Ref: https://core.telegram.org/bots/api#editmessagelivelocation
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to edit live location messages. A location can be edited
	until its *live_period* expires or editing is explicitly disabled by a
	call to stopMessageLiveLocation. On success, if the edited message is
	not an inline message, the edited Message is returned, otherwise *True*
	is returned.
	
	  Parameter                Type                   Required   Description
	  ------------------------ ---------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                  Integer or String      Optional   Required if *inline_message_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_id               Integer                Optional   Required if *inline_message_id* is not specified. Identifier of the message to edit
	  inline_message_id        String                 Optional   Required if *chat_id* and *message_id* are not specified. Identifier of the inline message
	  latitude                 Float number           Yes        Latitude of new location
	  longitude                Float number           Yes        Longitude of new location
	  horizontal_accuracy      Float number           Optional   The radius of uncertainty for the location, measured in meters; 0-1500
	  heading                  Integer                Optional   Direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
	  proximity_alert_radius   Integer                Optional   The maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
	  reply_markup             InlineKeyboardMarkup   Optional   A JSON-serialized object for a new inline keyboard.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/editMessageLiveLocation" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
