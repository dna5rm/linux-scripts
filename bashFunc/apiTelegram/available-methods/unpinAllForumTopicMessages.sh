## unpinallforumtopicmessages # Use this method to clear the list of pinned messages in a forum topic.
# https://core.telegram.org/bots/api#unpinallforumtopicmessages

function unpinAllForumTopicMessages ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to clear the list of pinned messages in a forum topic.
	Ref: https://core.telegram.org/bots/api#unpinallforumtopicmessages
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to clear the list of pinned messages in a forum topic.
The bot must be an administrator in the chat for this to work and must
have the *can_pin_messages* administrator right in the supergroup.
Returns *True* on success.
  Parameter           Type                Required   Description
  ------------------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------
  chat_id             Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
  message_thread_id   Integer             Yes        Unique identifier for the target message thread of the forum topic
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/unpinAllForumTopicMessages\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
