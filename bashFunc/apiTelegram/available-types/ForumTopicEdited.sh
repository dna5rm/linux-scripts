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
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/ForumTopicEdited\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
