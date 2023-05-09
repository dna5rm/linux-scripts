## chatpermissions # Describes actions that a non-administrator user is allowed to take in a chat.
# https://core.telegram.org/bots/api#chatpermissions

function ChatPermissions ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Describes actions that a non-administrator user is allowed to take in a chat.
	Ref: https://core.telegram.org/bots/api#chatpermissions
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Describes actions that a non-administrator user is allowed to take in a
chat.
  Field                       Type      Description
  --------------------------- --------- ------------------------------------------------------------------------------------------------------------------------------
  can_send_messages           Boolean   *Optional*. *True*, if the user is allowed to send text messages, contacts, invoices, locations and venues
  can_send_audios             Boolean   *Optional*. *True*, if the user is allowed to send audios
  can_send_documents          Boolean   *Optional*. *True*, if the user is allowed to send documents
  can_send_photos             Boolean   *Optional*. *True*, if the user is allowed to send photos
  can_send_videos             Boolean   *Optional*. *True*, if the user is allowed to send videos
  can_send_video_notes        Boolean   *Optional*. *True*, if the user is allowed to send video notes
  can_send_voice_notes        Boolean   *Optional*. *True*, if the user is allowed to send voice notes
  can_send_polls              Boolean   *Optional*. *True*, if the user is allowed to send polls
  can_send_other_messages     Boolean   *Optional*. *True*, if the user is allowed to send animations, games, stickers and use inline bots
  can_add_web_page_previews   Boolean   *Optional*. *True*, if the user is allowed to add web page previews to their messages
  can_change_info             Boolean   *Optional*. *True*, if the user is allowed to change the chat title, photo and other settings. Ignored in public supergroups
  can_invite_users            Boolean   *Optional*. *True*, if the user is allowed to invite new users to the chat
  can_pin_messages            Boolean   *Optional*. *True*, if the user is allowed to pin messages. Ignored in public supergroups
  can_manage_topics           Boolean   *Optional*. *True*, if the user is allowed to create forum topics. If omitted defaults to the value of can_pin_messages
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatPermissions\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
