## botcommandscopeallgroupchats # Represents the scope of bot commands, covering all group and supergroup chats.
# https://core.telegram.org/bots/api#botcommandscopeallgroupchats

function BotCommandScopeAllGroupChats ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the scope of bot commands, covering all group and supergroup chats.
	Ref: https://core.telegram.org/bots/api#botcommandscopeallgroupchats
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents the scope of bot commands, covering all group and supergroup
chats.
  Field   Type     Description
  ------- -------- ---------------------------------------
  type    String   Scope type, must be *all_group_chats*
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommandScopeAllGroupChats" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
