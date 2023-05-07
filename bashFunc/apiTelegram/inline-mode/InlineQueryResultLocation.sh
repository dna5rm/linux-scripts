## inlinequeryresultlocation # Represents a location on a map.
# https://core.telegram.org/bots/api#inlinequeryresultlocation

function InlineQueryResultLocation ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a location on a map.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultlocation
	---
	Represents a location on a map. By default, the location will be sent by
	the user. Alternatively, you can use *input_message_content* to send a
	message with the specified content instead of the location.
	
	  Field                    Type                   Description
	  ------------------------ ---------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  type                     String                 Type of the result, must be *location*
	  id                       String                 Unique identifier for this result, 1-64 Bytes
	  latitude                 Float number           Location latitude in degrees
	  longitude                Float number           Location longitude in degrees
	  title                    String                 Location title
	  horizontal_accuracy      Float number           *Optional*. The radius of uncertainty for the location, measured in meters; 0-1500
	  live_period              Integer                *Optional*. Period in seconds for which the location can be updated, should be between 60 and 86400.
	  heading                  Integer                *Optional*. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
	  proximity_alert_radius   Integer                *Optional*. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
	  reply_markup             InlineKeyboardMarkup   *Optional*. Inline keyboard attached to the message
	  input_message_content    InputMessageContent    *Optional*. Content of the message to be sent instead of the location
	  thumbnail_url            String                 *Optional*. Url of the thumbnail for the result
	  thumbnail_width          Integer                *Optional*. Thumbnail width
	  thumbnail_height         Integer                *Optional*. Thumbnail height
	
	**Note:** This will only work in Telegram versions released after 9
	April, 2016. Older clients will ignore them.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultLocation" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
