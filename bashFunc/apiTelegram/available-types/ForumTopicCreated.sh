## forumtopiccreated # This object represents a service message about a new forum topic created in the chat.
# https://core.telegram.org/bots/api#forumtopiccreated

function ForumTopicCreated ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a service message about a new forum topic created in the chat.
	Ref: https://core.telegram.org/bots/api#forumtopiccreated
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object represents a service message about a new forum topic created
	in the chat.
	
	  Field                  Type      Description
	  ---------------------- --------- ---------------------------------------------------------------------------
	  name                   String    Name of the topic
	  icon_color             Integer   Color of the topic icon in RGB format
	  icon_custom_emoji_id   String    *Optional*. Unique identifier of the custom emoji shown as the topic icon
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ForumTopicCreated" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
