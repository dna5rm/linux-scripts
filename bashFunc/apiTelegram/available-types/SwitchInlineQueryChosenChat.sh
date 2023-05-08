## switchinlinequerychosenchat # This object represents an inline button that switches the current user to inline mode in a chosen chat, with an optional default inline query.
# https://core.telegram.org/bots/api#switchinlinequerychosenchat

function SwitchInlineQueryChosenChat ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an inline button that switches the current user to inline mode in a chosen chat, with an optional default inline query.
	Ref: https://core.telegram.org/bots/api#switchinlinequerychosenchat
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents an inline button that switches the current user
to inline mode in a chosen chat, with an optional default inline query.
  Field                 Type      Description
  --------------------- --------- ----------------------------------------------------------------------------------------------------------------------------------
  query                 String    *Optional*. The default inline query to be inserted in the input field. If left empty, only the bot\'s username will be inserted
  allow_user_chats      Boolean   *Optional*. True, if private chats with users can be chosen
  allow_bot_chats       Boolean   *Optional*. True, if private chats with bots can be chosen
  allow_group_chats     Boolean   *Optional*. True, if group and supergroup chats can be chosen
  allow_channel_chats   Boolean   *Optional*. True, if channel chats can be chosen
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/SwitchInlineQueryChosenChat" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
