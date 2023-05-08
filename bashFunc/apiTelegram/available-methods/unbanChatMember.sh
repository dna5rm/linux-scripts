## unbanchatmember # Use this method to unban a previously banned user in a supergroup or channel.
# https://core.telegram.org/bots/api#unbanchatmember

function unbanChatMember ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to unban a previously banned user in a supergroup or channel.
	Ref: https://core.telegram.org/bots/api#unbanchatmember
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to unban a previously banned user in a supergroup or
channel. The user will **not** return to the group or channel
automatically, but will be able to join via link, etc. The bot must be
an administrator for this to work. By default, this method guarantees
that after the call the user is not a member of the chat, but will be
able to join it. So if the user is a member of the chat they will also
be **removed** from the chat. If you don\'t want this, use the parameter
*only_if_banned*. Returns *True* on success.
  Parameter        Type                Required   Description
  ---------------- ------------------- ---------- ---------------------------------------------------------------------------------------------------------------------------
  chat_id          Integer or String   Yes        Unique identifier for the target group or username of the target supergroup or channel (in the format `@channelusername`)
  user_id          Integer             Yes        Unique identifier of the target user
  only_if_banned   Boolean             Optional   Do nothing if the user is not banned
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/unbanChatMember" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
