## getwebhookinfo # Use this method to get current webhook status.
# https://core.telegram.org/bots/api#getwebhookinfo

function getWebhookInfo ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get current webhook status.
	Ref: https://core.telegram.org/bots/api#getwebhookinfo
	---
	Use this method to get current webhook status. Requires no parameters.
	On success, returns a WebhookInfo object. If the bot is using
	getUpdates, will return an object with the *url* field empty.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getWebhookInfo" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
