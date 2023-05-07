## botcommandscope # This object represents the scope to which bot commands are applied.
# https://core.telegram.org/bots/api#botcommandscope

function BotCommandScope ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents the scope to which bot commands are applied.
	Ref: https://core.telegram.org/bots/api#botcommandscope
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object represents the scope to which bot commands are applied.
	Currently, the following 7 scopes are supported:
	
	-   BotCommandScopeDefault
	-   BotCommandScopeAllPrivateChats
	-   BotCommandScopeAllGroupChats
	-   BotCommandScopeAllChatAdministrators
	-   BotCommandScopeChat
	-   BotCommandScopeChatAdministrators
	-   BotCommandScopeChatMember
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommandScope" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
