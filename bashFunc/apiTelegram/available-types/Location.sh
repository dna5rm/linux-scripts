## location # This object represents a point on the map.
# https://core.telegram.org/bots/api#location

function Location ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a point on the map.
	Ref: https://core.telegram.org/bots/api#location
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a point on the map.
  Field                    Type           Description
  ------------------------ -------------- ----------------------------------------------------------------------------------------------------------------------------------------------
  longitude                Float          Longitude as defined by sender
  latitude                 Float          Latitude as defined by sender
  horizontal_accuracy      Float number   *Optional*. The radius of uncertainty for the location, measured in meters; 0-1500
  live_period              Integer        *Optional*. Time relative to the message sending date, during which the location can be updated; in seconds. For active live locations only.
  heading                  Integer        *Optional*. The direction in which user is moving, in degrees; 1-360. For active live locations only.
  proximity_alert_radius   Integer        *Optional*. The maximum distance for proximity alerts about approaching another chat member, in meters. For sent live locations only.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/Location" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
