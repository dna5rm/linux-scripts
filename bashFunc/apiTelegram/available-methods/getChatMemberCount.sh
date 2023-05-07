## getchatmembercount # Use this method to get the number of members in a chat.
# https://core.telegram.org/bots/api#getchatmembercount

function getChatMemberCount ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get the number of members in a chat.
	Ref: https://core.telegram.org/bots/api#getchatmembercount
	---
	Use this method to get the number of members in a chat. Returns *Int* on
	success.
	
	  Parameter   Type                Required   Description
	  ----------- ------------------- ---------- --------------------------------------------------------------------------------------------------------------------------
	  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getChatMemberCount" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
