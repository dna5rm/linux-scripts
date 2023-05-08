## forumtopicedited # This object represents a service message about an edited forum topic.
# https://core.telegram.org/bots/api#forumtopicedited

function ForumTopicEdited ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a service message about an edited forum topic.
	Ref: https://core.telegram.org/bots/api#forumtopicedited
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a service message about an edited forum topic.
  Field                  Type     Description
  ---------------------- -------- -----------------------------------------------------------------------------------------------------------------------------------
  name                   String   *Optional*. New name of the topic, if it was edited
  icon_custom_emoji_id   String   *Optional*. New identifier of the custom emoji shown as the topic icon, if it was edited; an empty string if the icon was removed
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ForumTopicEdited" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
