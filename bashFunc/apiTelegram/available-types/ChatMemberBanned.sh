## chatmemberbanned # Represents a chat member that was banned in the chat and can't return to the chat or view chat messages.
# https://core.telegram.org/bots/api#chatmemberbanned

function ChatMemberBanned ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a chat member that was banned in the chat and can't return to the chat or view chat messages.
	Ref: https://core.telegram.org/bots/api#chatmemberbanned
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents a chat member that was banned in the chat and can't return
	to the chat or view chat messages.
	
	  Field        Type      Description
	  ------------ --------- -------------------------------------------------------------------------------------------------------
	  status       String    The member's status in the chat, always "kicked"
	  user         User      Information about the user
	  until_date   Integer   Date when restrictions will be lifted for this user; unix time. If 0, then the user is banned forever
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMemberBanned" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
