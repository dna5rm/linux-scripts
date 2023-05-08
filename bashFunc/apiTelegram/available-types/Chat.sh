## chat # This object represents a chat.
# https://core.telegram.org/bots/api#chat

function Chat ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a chat.
	Ref: https://core.telegram.org/bots/api#chat
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a chat.
  Field                                     Type              Description
  ----------------------------------------- ----------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  id                                        Integer           Unique identifier for this chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.
  type                                      String            Type of chat, can be either "private", "group", "supergroup" or "channel"
  title                                     String            *Optional*. Title, for supergroups, channels and group chats
  username                                  String            *Optional*. Username, for private chats, supergroups and channels if available
  first_name                                String            *Optional*. First name of the other party in a private chat
  last_name                                 String            *Optional*. Last name of the other party in a private chat
  is_forum                                  True              *Optional*. *True*, if the supergroup chat is a forum (has topics enabled)
  photo                                     ChatPhoto         *Optional*. Chat photo. Returned only in getChat.
  active_usernames                          Array of String   *Optional*. If non-empty, the list of all active chat usernames; for private chats, supergroups and channels. Returned only in getChat.
  emoji_status_custom_emoji_id              String            *Optional*. Custom emoji identifier of emoji status of the other party in a private chat. Returned only in getChat.
  bio                                       String            *Optional*. Bio of the other party in a private chat. Returned only in getChat.
  has_private_forwards                      True              *Optional*. *True*, if privacy settings of the other party in the private chat allows to use `tg://user?id=<user_id>` links only in chats with the user. Returned only in getChat.
  has_restricted_voice_and_video_messages   True              *Optional*. *True*, if the privacy settings of the other party restrict sending voice and video note messages in the private chat. Returned only in getChat.
  join_to_send_messages                     True              *Optional*. *True*, if users need to join the supergroup before they can send messages. Returned only in getChat.
  join_by_request                           True              *Optional*. *True*, if all users directly joining the supergroup need to be approved by supergroup administrators. Returned only in getChat.
  description                               String            *Optional*. Description, for groups, supergroups and channel chats. Returned only in getChat.
  invite_link                               String            *Optional*. Primary invite link, for groups, supergroups and channel chats. Returned only in getChat.
  pinned_message                            Message           *Optional*. The most recent pinned message (by sending date). Returned only in getChat.
  permissions                               ChatPermissions   *Optional*. Default chat member permissions, for groups and supergroups. Returned only in getChat.
  slow_mode_delay                           Integer           *Optional*. For supergroups, the minimum allowed delay between consecutive messages sent by each unpriviledged user; in seconds. Returned only in getChat.
  message_auto_delete_time                  Integer           *Optional*. The time after which all messages sent to the chat will be automatically deleted; in seconds. Returned only in getChat.
  has_aggressive_anti_spam_enabled          True              *Optional*. *True*, if aggressive anti-spam checks are enabled in the supergroup. The field is only available to chat administrators. Returned only in getChat.
  has_hidden_members                        True              *Optional*. *True*, if non-administrators can only get the list of bots and administrators in the chat. Returned only in getChat.
  has_protected_content                     True              *Optional*. *True*, if messages from the chat can\'t be forwarded to other chats. Returned only in getChat.
  sticker_set_name                          String            *Optional*. For supergroups, name of group sticker set. Returned only in getChat.
  can_set_sticker_set                       True              *Optional*. *True*, if the bot can change the group sticker set. Returned only in getChat.
  linked_chat_id                            Integer           *Optional*. Unique identifier for the linked chat, i.e. the discussion group identifier for a channel and vice versa; for supergroups and channel chats. This identifier may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier. Returned only in getChat.
  location                                  ChatLocation      *Optional*. For supergroups, the location to which the supergroup is connected. Returned only in getChat.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/Chat" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
