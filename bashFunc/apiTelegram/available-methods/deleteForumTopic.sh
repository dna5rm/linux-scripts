## deleteforumtopic # Use this method to delete a forum topic along with all its messages in a forum supergroup chat.
# https://core.telegram.org/bots/api#deleteforumtopic

function deleteForumTopic ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to delete a forum topic along with all its messages in a forum supergroup chat.
	Ref: https://core.telegram.org/bots/api#deleteforumtopic
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to delete a forum topic along with all its messages in a
	forum supergroup chat. The bot must be an administrator in the chat for
	this to work and must have the *can_delete_messages* administrator
	rights. Returns *True* on success.
	
	  Parameter           Type                Required   Description
	  ------------------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------
	  chat_id             Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format \`@supergroupusername\`)
	  message_thread_id   Integer             Yes        Unique identifier for the target message thread of the forum topic
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/deleteForumTopic" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
