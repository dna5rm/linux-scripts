## chatmember # This object contains information about one member of a chat.
# https://core.telegram.org/bots/api#chatmember

function ChatMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object contains information about one member of a chat.
	Ref: https://core.telegram.org/bots/api#chatmember
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object contains information about one member of a chat. Currently,
	the following 6 types of chat members are supported:
	
	-   ChatMemberOwner
	-   ChatMemberAdministrator
	-   ChatMemberMember
	-   ChatMemberRestricted
	-   ChatMemberLeft
	-   ChatMemberBanned
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatMember" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
