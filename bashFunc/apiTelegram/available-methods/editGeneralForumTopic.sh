## editgeneralforumtopic # Use this method to edit the name of the 'General' topic in a forum supergroup chat.
# https://core.telegram.org/bots/api#editgeneralforumtopic

function editGeneralForumTopic ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to edit the name of the 'General' topic in a forum supergroup chat.
	Ref: https://core.telegram.org/bots/api#editgeneralforumtopic
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to edit the name of the \'General\' topic in a forum
supergroup chat. The bot must be an administrator in the chat for this
to work and must have *can_manage_topics* administrator rights. Returns
*True* on success.
  Parameter   Type                Required   Description
  ----------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------
  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
  name        String              Yes        New topic name, 1-128 characters
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/editGeneralForumTopic" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
