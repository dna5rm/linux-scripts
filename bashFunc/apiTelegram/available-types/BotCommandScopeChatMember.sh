## botcommandscopechatmember # Represents the scope of bot commands, covering a specific member of a group or supergroup chat.
# https://core.telegram.org/bots/api#botcommandscopechatmember

function BotCommandScopeChatMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the scope of bot commands, covering a specific member of a group or supergroup chat.
	Ref: https://core.telegram.org/bots/api#botcommandscopechatmember
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents the scope of bot commands, covering a specific member of a
group or supergroup chat.
  Field     Type                Description
  --------- ------------------- ------------------------------------------------------------------------------------------------------------------
  type      String              Scope type, must be *chat_member*
  chat_id   Integer or String   Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
  user_id   Integer             Unique identifier of the target user
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommandScopeChatMember\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
