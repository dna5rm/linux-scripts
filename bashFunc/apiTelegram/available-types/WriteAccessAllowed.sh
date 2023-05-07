## writeaccessallowed # This object represents a service message about a user allowing a bot to write messages after adding the bot to the attachment menu or launching a Web App from a link.
# https://core.telegram.org/bots/api#writeaccessallowed

function WriteAccessAllowed ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a service message about a user allowing a bot to write messages after adding the bot to the attachment menu or launching a Web App from a link.
	Ref: https://core.telegram.org/bots/api#writeaccessallowed
	---
	This object represents a service message about a user allowing a bot to
	write messages after adding the bot to the attachment menu or launching
	a Web App from a link.
	
	  Field          Type     Description
	  -------------- -------- ----------------------------------------------------------------
	  web_app_name   String   *Optional*. Name of the Web App which was launched from a link
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/WriteAccessAllowed" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
