## chatmemberrestricted # Represents a chat member that is under certain restrictions in the chat.
# https://core.telegram.org/bots/api#chatmemberrestricted

function ChatMemberRestricted ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a chat member that is under certain restrictions in the chat.
	Ref: https://core.telegram.org/bots/api#chatmemberrestricted
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a chat member that is under certain restrictions in the chat.
Supergroups only.
  Field                       Type      Description
  --------------------------- --------- -----------------------------------------------------------------------------------------------------------
  status                      String    The member\'s status in the chat, always "restricted"
  user                        User      Information about the user
  is_member                   Boolean   *True*, if the user is a member of the chat at the moment of the request
  can_send_messages           Boolean   *True*, if the user is allowed to send text messages, contacts, invoices, locations and venues
  can_send_audios             Boolean   *True*, if the user is allowed to send audios
  can_send_documents          Boolean   *True*, if the user is allowed to send documents
  can_send_photos             Boolean   *True*, if the user is allowed to send photos
  can_send_videos             Boolean   *True*, if the user is allowed to send videos
  can_send_video_notes        Boolean   *True*, if the user is allowed to send video notes
  can_send_voice_notes        Boolean   *True*, if the user is allowed to send voice notes
  can_send_polls              Boolean   *True*, if the user is allowed to send polls
  can_send_other_messages     Boolean   *True*, if the user is allowed to send animations, games, stickers and use inline bots
  can_add_web_page_previews   Boolean   *True*, if the user is allowed to add web page previews to their messages
  can_change_info             Boolean   *True*, if the user is allowed to change the chat title, photo and other settings
  can_invite_users            Boolean   *True*, if the user is allowed to invite new users to the chat
  can_pin_messages            Boolean   *True*, if the user is allowed to pin messages
  can_manage_topics           Boolean   *True*, if the user is allowed to create forum topics
  until_date                  Integer   Date when restrictions will be lifted for this user; unix time. If 0, then the user is restricted forever
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMemberRestricted\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
