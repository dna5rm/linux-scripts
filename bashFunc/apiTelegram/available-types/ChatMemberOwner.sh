## chatmemberowner # Represents a chat member that owns the chat and has all administrator privileges.
# https://core.telegram.org/bots/api#chatmemberowner

function ChatMemberOwner ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a chat member that owns the chat and has all administrator privileges.
	Ref: https://core.telegram.org/bots/api#chatmemberowner
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a chat member that owns the chat and has all administrator
privileges.
  Field          Type      Description
  -------------- --------- -------------------------------------------------------
  status         String    The member\'s status in the chat, always "creator"
  user           User      Information about the user
  is_anonymous   Boolean   *True*, if the user\'s presence in the chat is hidden
  custom_title   String    *Optional*. Custom title for this user
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMemberOwner\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
