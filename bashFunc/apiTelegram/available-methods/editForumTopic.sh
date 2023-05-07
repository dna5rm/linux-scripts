## editforumtopic # Use this method to edit name and icon of a topic in a forum supergroup chat.
# https://core.telegram.org/bots/api#editforumtopic

function editForumTopic ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to edit name and icon of a topic in a forum supergroup chat.
	Ref: https://core.telegram.org/bots/api#editforumtopic
	---
	Use this method to edit name and icon of a topic in a forum supergroup
	chat. The bot must be an administrator in the chat for this to work and
	must have *can_manage_topics* administrator rights, unless it is the
	creator of the topic. Returns *True* on success.
	
	  Parameter              Type                Required   Description
	  ---------------------- ------------------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
	  message_thread_id      Integer             Yes        Unique identifier for the target message thread of the forum topic
	  name                   String              Optional   New topic name, 0-128 characters. If not specified or empty, the current name of the topic will be kept
	  icon_custom_emoji_id   String              Optional   New unique identifier of the custom emoji shown as the topic icon. Use getForumTopicIconStickers to get all allowed custom emoji identifiers. Pass an empty string to remove the icon. If not specified, the current icon will be kept
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/editForumTopic" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
