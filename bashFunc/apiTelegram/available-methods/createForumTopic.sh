## createforumtopic # Use this method to create a topic in a forum supergroup chat.
# https://core.telegram.org/bots/api#createforumtopic

function createForumTopic ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to create a topic in a forum supergroup chat.
	Ref: https://core.telegram.org/bots/api#createforumtopic
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to create a topic in a forum supergroup chat. The bot
	must be an administrator in the chat for this to work and must have the
	*can_manage_topics* administrator rights. Returns information about the
	created topic as a ForumTopic object.
	
	  Parameter              Type                Required   Description
	  ---------------------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format \`@supergroupusername\`)
	  name                   String              Yes        Topic name, 1-128 characters
	  icon_color             Integer             Optional   Color of the topic icon in RGB format. Currently, must be one of 7322096 (0x6FB9F0), 16766590 (0xFFD67E), 13338331 (0xCB86DB), 9367192 (0x8EEE98), 16749490 (0xFF93B2), or 16478047 (0xFB6F5F)
	  icon_custom_emoji_id   String              Optional   Unique identifier of the custom emoji shown as the topic icon. Use getForumTopicIconStickers to get all allowed custom emoji identifiers.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/createForumTopic" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
