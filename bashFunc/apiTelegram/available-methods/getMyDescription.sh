## getmydescription # Use this method to get the current bot description for the given user language.
# https://core.telegram.org/bots/api#getmydescription

function getMyDescription ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get the current bot description for the given user language.
	Ref: https://core.telegram.org/bots/api#getmydescription
	---
	Use this method to get the current bot description for the given user
	language. Returns BotDescription on success.
	
	  Parameter       Type     Required   Description
	  --------------- -------- ---------- ---------------------------------------------------------
	  language_code   String   Optional   A two-letter ISO 639-1 language code or an empty string
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getMyDescription" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
