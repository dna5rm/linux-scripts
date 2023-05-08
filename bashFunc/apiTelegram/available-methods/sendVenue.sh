## sendvenue # Use this method to send information about a venue.
# https://core.telegram.org/bots/api#sendvenue

function sendVenue ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send information about a venue.
	Ref: https://core.telegram.org/bots/api#sendvenue
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to send information about a venue. On success, the sent
Message is returned.
  Parameter                     Type                                                                               Required   Description
  ----------------------------- ---------------------------------------------------------------------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  chat_id                       Integer or String                                                                  Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
  message_thread_id             Integer                                                                            Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
  latitude                      Float number                                                                       Yes        Latitude of the venue
  longitude                     Float number                                                                       Yes        Longitude of the venue
  title                         String                                                                             Yes        Name of the venue
  address                       String                                                                             Yes        Address of the venue
  foursquare_id                 String                                                                             Optional   Foursquare identifier of the venue
  foursquare_type               String                                                                             Optional   Foursquare type of the venue, if known. (For example, "arts_entertainment/default", "arts_entertainment/aquarium" or "food/icecream".)
  google_place_id               String                                                                             Optional   Google Places identifier of the venue
  google_place_type             String                                                                             Optional   Google Places type of the venue. (See supported types.)
  disable_notification          Boolean                                                                            Optional   Sends the message silently. Users will receive a notification with no sound.
  protect_content               Boolean                                                                            Optional   Protects the contents of the sent message from forwarding and saving
  reply_to_message_id           Integer                                                                            Optional   If the message is a reply, ID of the original message
  allow_sending_without_reply   Boolean                                                                            Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
  reply_markup                  InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardRemove or ForceReply   Optional   Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendVenue" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
