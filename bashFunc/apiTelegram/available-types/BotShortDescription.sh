## botshortdescription # This object represents the bot's short description.
# https://core.telegram.org/bots/api#botshortdescription

function BotShortDescription ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents the bot's short description.
	Ref: https://core.telegram.org/bots/api#botshortdescription
	---
	This object represents the bot's short description.
	
	  Field               Type     Description
	  ------------------- -------- ------------------------------
	  short_description   String   The bot's short description
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotShortDescription" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
