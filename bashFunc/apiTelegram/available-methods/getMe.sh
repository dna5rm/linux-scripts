## getme # A simple method for testing your bot's authentication token.
# https://core.telegram.org/bots/api#getme

function getMe ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${TELEGRAM_TOKEN}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - A simple method for testing your bot's authentication token.
	Ref: https://core.telegram.org/bots/api#getme
	---
	A simple method for testing your bot's authentication token. Requires
	no parameters. Returns basic information about the bot in form of a User
	object.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getMe" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json"
    fi
}
