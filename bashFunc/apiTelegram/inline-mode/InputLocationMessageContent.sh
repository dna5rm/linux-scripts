## inputlocationmessagecontent # Represents the content of a location message to be sent as the result of an inline query.
# https://core.telegram.org/bots/api#inputlocationmessagecontent

function InputLocationMessageContent ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the content of a location message to be sent as the result of an inline query.
	Ref: https://core.telegram.org/bots/api#inputlocationmessagecontent
	---
	Represents the content of a location message to be sent as the result of
	an inline query.
	
	  Field                    Type           Description
	  ------------------------ -------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  latitude                 Float          Latitude of the location in degrees
	  longitude                Float          Longitude of the location in degrees
	  horizontal_accuracy      Float number   *Optional*. The radius of uncertainty for the location, measured in meters; 0-1500
	  live_period              Integer        *Optional*. Period in seconds for which the location can be updated, should be between 60 and 86400.
	  heading                  Integer        *Optional*. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.
	  proximity_alert_radius   Integer        *Optional*. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputLocationMessageContent" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
