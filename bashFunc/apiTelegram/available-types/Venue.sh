## venue # This object represents a venue.
# https://core.telegram.org/bots/api#venue

function Venue ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a venue.
	Ref: https://core.telegram.org/bots/api#venue
	---
	This object represents a venue.
	
	  Field               Type       Description
	  ------------------- ---------- ------------------------------------------------------------------------------------------------------------------------------------------
	  location            Location   Venue location. Can't be a live location
	  title               String     Name of the venue
	  address             String     Address of the venue
	  foursquare_id       String     *Optional*. Foursquare identifier of the venue
	  foursquare_type     String     *Optional*. Foursquare type of the venue. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
	  google_place_id     String     *Optional*. Google Places identifier of the venue
	  google_place_type   String     *Optional*. Google Places type of the venue. (See supported types.)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/Venue" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
