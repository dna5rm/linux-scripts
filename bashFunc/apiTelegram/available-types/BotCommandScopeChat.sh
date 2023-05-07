## botcommandscopechat # Represents the scope of bot commands, covering a specific chat.
# https://core.telegram.org/bots/api#botcommandscopechat

function BotCommandScopeChat ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the scope of bot commands, covering a specific chat.
	Ref: https://core.telegram.org/bots/api#botcommandscopechat
	---
	Represents the scope of bot commands, covering a specific chat.
	
	  Field     Type                Description
	  --------- ------------------- ------------------------------------------------------------------------------------------------------------------
	  type      String              Scope type, must be *chat*
	  chat_id   Integer or String   Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommandScopeChat" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
