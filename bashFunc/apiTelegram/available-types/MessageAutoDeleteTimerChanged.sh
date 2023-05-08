## messageautodeletetimerchanged # This object represents a service message about a change in auto-delete timer settings.
# https://core.telegram.org/bots/api#messageautodeletetimerchanged

function MessageAutoDeleteTimerChanged ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a service message about a change in auto-delete timer settings.
	Ref: https://core.telegram.org/bots/api#messageautodeletetimerchanged
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a service message about a change in auto-delete
timer settings.
  Field                      Type      Description
  -------------------------- --------- -----------------------------------------------------------
  message_auto_delete_time   Integer   New auto-delete time for messages in the chat; in seconds
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/MessageAutoDeleteTimerChanged" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
