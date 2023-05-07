## generalforumtopichidden # This object represents a service message about General forum topic hidden in the chat.
# https://core.telegram.org/bots/api#generalforumtopichidden

function GeneralForumTopicHidden ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a service message about General forum topic hidden in the chat.
	Ref: https://core.telegram.org/bots/api#generalforumtopichidden
	---
	This object represents a service message about General forum topic
	hidden in the chat. Currently holds no information.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/GeneralForumTopicHidden" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
