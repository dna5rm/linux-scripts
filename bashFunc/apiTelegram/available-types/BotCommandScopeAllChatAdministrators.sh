## botcommandscopeallchatadministrators # Represents the scope of bot commands, covering all group and supergroup chat administrators.
# https://core.telegram.org/bots/api#botcommandscopeallchatadministrators

function BotCommandScopeAllChatAdministrators ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the scope of bot commands, covering all group and supergroup chat administrators.
	Ref: https://core.telegram.org/bots/api#botcommandscopeallchatadministrators
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents the scope of bot commands, covering all group and supergroup
	chat administrators.
	
	  Field   Type     Description
	  ------- -------- -----------------------------------------------
	  type    String   Scope type, must be *all_chat_administrators*
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommandScopeAllChatAdministrators" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
