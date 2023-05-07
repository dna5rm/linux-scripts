## close # Use this method to close the bot instance before moving it from one local server to another.
# https://core.telegram.org/bots/api#close

function close ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to close the bot instance before moving it from one local server to another.
	Ref: https://core.telegram.org/bots/api#close
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to close the bot instance before moving it from one
	local server to another. You need to delete the webhook before calling
	this method to ensure that the bot isn't launched again after server
	restart. The method will return error 429 in the first 10 minutes after
	the bot is launched. Returns *True* on success. Requires no parameters.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/close" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
