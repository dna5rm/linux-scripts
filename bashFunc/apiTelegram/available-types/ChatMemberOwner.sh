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
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMemberOwner" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
