## videochatparticipantsinvited # This object represents a service message about new members invited to a video chat.
# https://core.telegram.org/bots/api#videochatparticipantsinvited

function VideoChatParticipantsInvited ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a service message about new members invited to a video chat.
	Ref: https://core.telegram.org/bots/api#videochatparticipantsinvited
	---
	This object represents a service message about new members invited to a
	video chat.
	
	  Field   Type            Description
	  ------- --------------- -------------------------------------------------
	  users   Array of User   New members that were invited to the video chat
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/VideoChatParticipantsInvited" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
