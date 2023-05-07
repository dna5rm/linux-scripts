## closegeneralforumtopic # Use this method to close an open 'General' topic in a forum supergroup chat.
# https://core.telegram.org/bots/api#closegeneralforumtopic

function closeGeneralForumTopic ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to close an open 'General' topic in a forum supergroup chat.
	Ref: https://core.telegram.org/bots/api#closegeneralforumtopic
	---
	Use this method to close an open 'General' topic in a forum supergroup
	chat. The bot must be an administrator in the chat for this to work and
	must have the *can_manage_topics* administrator rights. Returns *True*
	on success.
	
	  Parameter   Type                Required   Description
	  ----------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------
	  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/closeGeneralForumTopic" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
