## botcommandscopechatadministrators # Represents the scope of bot commands, covering all administrators of a specific group or supergroup chat.
# https://core.telegram.org/bots/api#botcommandscopechatadministrators

function BotCommandScopeChatAdministrators ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the scope of bot commands, covering all administrators of a specific group or supergroup chat.
	Ref: https://core.telegram.org/bots/api#botcommandscopechatadministrators
	---
	Represents the scope of bot commands, covering all administrators of a
	specific group or supergroup chat.
	
	  Field     Type                Description
	  --------- ------------------- ------------------------------------------------------------------------------------------------------------------
	  type      String              Scope type, must be *chat_administrators*
	  chat_id   Integer or String   Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommandScopeChatAdministrators" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
