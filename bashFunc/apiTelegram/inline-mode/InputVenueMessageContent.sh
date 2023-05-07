## inputvenuemessagecontent # Represents the content of a venue message to be sent as the result of an inline query.
# https://core.telegram.org/bots/api#inputvenuemessagecontent

function InputVenueMessageContent ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the content of a venue message to be sent as the result of an inline query.
	Ref: https://core.telegram.org/bots/api#inputvenuemessagecontent
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents the content of a venue message to be sent as the result of an
	inline query.
	
	  Field               Type     Description
	  ------------------- -------- ----------------------------------------------------------------------------------------------------------------------------------------------------
	  latitude            Float    Latitude of the venue in degrees
	  longitude           Float    Longitude of the venue in degrees
	  title               String   Name of the venue
	  address             String   Address of the venue
	  foursquare_id       String   *Optional*. Foursquare identifier of the venue, if known
	  foursquare_type     String   *Optional*. Foursquare type of the venue, if known. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
	  google_place_id     String   *Optional*. Google Places identifier of the venue
	  google_place_type   String   *Optional*. Google Places type of the venue. (See supported types.)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputVenueMessageContent" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
