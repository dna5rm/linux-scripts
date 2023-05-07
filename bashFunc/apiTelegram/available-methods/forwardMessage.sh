## forwardmessage # Use this method to forward messages of any kind.
# https://core.telegram.org/bots/api#forwardmessage

function forwardMessage ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to forward messages of any kind.
	Ref: https://core.telegram.org/bots/api#forwardmessage
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to forward messages of any kind. Service messages can't
	be forwarded. On success, the sent Message is returned.
	
	  Parameter              Type                Required   Description
	  ---------------------- ------------------- ---------- ---------------------------------------------------------------------------------------------------------------------------
	  chat_id                Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_thread_id      Integer             Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
	  from_chat_id           Integer or String   Yes        Unique identifier for the chat where the original message was sent (or channel username in the format \`@channelusername\`)
	  disable_notification   Boolean             Optional   Sends the message silently. Users will receive a notification with no sound.
	  protect_content        Boolean             Optional   Protects the contents of the forwarded message from forwarding and saving
	  message_id             Integer             Yes        Message identifier in the chat specified in *from_chat_id*
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/forwardMessage" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
