## videochatscheduled # This object represents a service message about a video chat scheduled in the chat.
# https://core.telegram.org/bots/api#videochatscheduled

function VideoChatScheduled ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a service message about a video chat scheduled in the chat.
	Ref: https://core.telegram.org/bots/api#videochatscheduled
	---
	This object represents a service message about a video chat scheduled in
	the chat.
	
	  Field        Type      Description
	  ------------ --------- ------------------------------------------------------------------------------------------------------
	  start_date   Integer   Point in time (Unix timestamp) when the video chat is supposed to be started by a chat administrator
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/VideoChatScheduled" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
