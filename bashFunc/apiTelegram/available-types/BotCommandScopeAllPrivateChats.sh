## botcommandscopeallprivatechats # Represents the scope of bot commands, covering all private chats.
# https://core.telegram.org/bots/api#botcommandscopeallprivatechats

function BotCommandScopeAllPrivateChats ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the scope of bot commands, covering all private chats.
	Ref: https://core.telegram.org/bots/api#botcommandscopeallprivatechats
	---
	Represents the scope of bot commands, covering all private chats.
	
	  Field   Type     Description
	  ------- -------- -----------------------------------------
	  type    String   Scope type, must be *all_private_chats*
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommandScopeAllPrivateChats" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
