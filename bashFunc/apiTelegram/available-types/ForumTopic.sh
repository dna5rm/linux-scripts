## forumtopic # This object represents a forum topic.
# https://core.telegram.org/bots/api#forumtopic

function ForumTopic ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a forum topic.
	Ref: https://core.telegram.org/bots/api#forumtopic
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a forum topic.
  Field                  Type      Description
  ---------------------- --------- ---------------------------------------------------------------------------
  message_thread_id      Integer   Unique identifier of the forum topic
  name                   String    Name of the topic
  icon_color             Integer   Color of the topic icon in RGB format
  icon_custom_emoji_id   String    *Optional*. Unique identifier of the custom emoji shown as the topic icon
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ForumTopic" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
