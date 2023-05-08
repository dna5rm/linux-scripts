## getchat # Use this method to get up to date information about the chat (current name of the user for one-on-one conversations, current username of a user, group or channel, etc.
# https://core.telegram.org/bots/api#getchat

function getChat ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get up to date information about the chat (current name of the user for one-on-one conversations, current username of a user, group or channel, etc.
	Ref: https://core.telegram.org/bots/api#getchat
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to get up to date information about the chat (current
name of the user for one-on-one conversations, current username of a
user, group or channel, etc.). Returns a Chat object on success.
  Parameter   Type                Required   Description
  ----------- ------------------- ---------- --------------------------------------------------------------------------------------------------------------------------
  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getChat" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
