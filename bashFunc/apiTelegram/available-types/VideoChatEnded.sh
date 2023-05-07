## videochatended # This object represents a service message about a video chat ended in the chat.
# https://core.telegram.org/bots/api#videochatended

function VideoChatEnded ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a service message about a video chat ended in the chat.
	Ref: https://core.telegram.org/bots/api#videochatended
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object represents a service message about a video chat ended in the
	chat.
	
	  Field      Type      Description
	  ---------- --------- --------------------------------
	  duration   Integer   Video chat duration in seconds
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/VideoChatEnded" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
