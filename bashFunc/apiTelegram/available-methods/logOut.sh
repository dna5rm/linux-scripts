## logout # Use this method to log out from the cloud Bot API server before launching the bot locally.
# https://core.telegram.org/bots/api#logout

function logOut ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to log out from the cloud Bot API server before launching the bot locally.
	Ref: https://core.telegram.org/bots/api#logout
	---
	Use this method to log out from the cloud Bot API server before
	launching the bot locally. You **must** log out the bot before running
	it locally, otherwise there is no guarantee that the bot will receive
	updates. After a successful call, you can immediately log in on a local
	server, but will not be able to log in back to the cloud Bot API server
	for 10 minutes. Returns *True* on success. Requires no parameters.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/logOut" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
