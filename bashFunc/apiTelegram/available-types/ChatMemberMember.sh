## chatmembermember # Represents a chat member that has no additional privileges or restrictions.
# https://core.telegram.org/bots/api#chatmembermember

function ChatMemberMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a chat member that has no additional privileges or restrictions.
	Ref: https://core.telegram.org/bots/api#chatmembermember
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a chat member that has no additional privileges or
	restrictions.
	
	  Field    Type     Description
	  -------- -------- ---------------------------------------------------
	  status   String   The member's status in the chat, always "member"
	  user     User     Information about the user
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMemberMember" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
