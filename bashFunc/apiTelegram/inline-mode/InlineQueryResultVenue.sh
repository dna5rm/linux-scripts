## inlinequeryresultvenue # Represents a venue.
# https://core.telegram.org/bots/api#inlinequeryresultvenue

function InlineQueryResultVenue ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a venue.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultvenue
	---
	Represents a venue. By default, the venue will be sent by the user.
	Alternatively, you can use *input_message_content* to send a message
	with the specified content instead of the venue.
	
	  Field                   Type                   Description
	  ----------------------- ---------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------
	  type                    String                 Type of the result, must be *venue*
	  id                      String                 Unique identifier for this result, 1-64 Bytes
	  latitude                Float                  Latitude of the venue location in degrees
	  longitude               Float                  Longitude of the venue location in degrees
	  title                   String                 Title of the venue
	  address                 String                 Address of the venue
	  foursquare_id           String                 *Optional*. Foursquare identifier of the venue if known
	  foursquare_type         String                 *Optional*. Foursquare type of the venue, if known. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
	  google_place_id         String                 *Optional*. Google Places identifier of the venue
	  google_place_type       String                 *Optional*. Google Places type of the venue. (See supported types.)
	  reply_markup            InlineKeyboardMarkup   *Optional*. Inline keyboard attached to the message
	  input_message_content   InputMessageContent    *Optional*. Content of the message to be sent instead of the venue
	  thumbnail_url           String                 *Optional*. Url of the thumbnail for the result
	  thumbnail_width         Integer                *Optional*. Thumbnail width
	  thumbnail_height        Integer                *Optional*. Thumbnail height
	
	**Note:** This will only work in Telegram versions released after 9
	April, 2016. Older clients will ignore them.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultVenue" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
