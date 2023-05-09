## restrictchatmember # Use this method to restrict a user in a supergroup.
# https://core.telegram.org/bots/api#restrictchatmember

function restrictChatMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to restrict a user in a supergroup.
	Ref: https://core.telegram.org/bots/api#restrictchatmember
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to restrict a user in a supergroup. The bot must be an
administrator in the supergroup for this to work and must have the
appropriate administrator rights. Pass *True* for all permissions to
lift restrictions from a user. Returns *True* on success.
  Parameter                          Type                Required   Description
  ---------------------------------- ------------------- ---------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  chat_id                            Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
  user_id                            Integer             Yes        Unique identifier of the target user
  permissions                        ChatPermissions     Yes        A JSON-serialized object for new user permissions
  use_independent_chat_permissions   Boolean             Optional   Pass *True* if chat permissions are set independently. Otherwise, the *can_send_other_messages* and *can_add_web_page_previews* permissions will imply the *can_send_messages*, *can_send_audios*, *can_send_documents*, *can_send_photos*, *can_send_videos*, *can_send_video_notes*, and *can_send_voice_notes* permissions; the *can_send_polls* permission will imply the *can_send_messages* permission.
  until_date                         Integer             Optional   Date when restrictions will be lifted for the user, unix time. If user is restricted for more than 366 days or less than 30 seconds from the current time, they are considered to be restricted forever
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/restrictChatMember\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
