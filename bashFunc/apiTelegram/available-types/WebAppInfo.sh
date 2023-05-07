## webappinfo # Describes a Web App.
# https://core.telegram.org/bots/api#webappinfo

function WebAppInfo ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Describes a Web App.
	Ref: https://core.telegram.org/bots/api#webappinfo
	---
	Describes a Web App.
	
	  Field   Type     Description
	  ------- -------- ---------------------------------------------------------------------------------------------------
	  url     String   An HTTPS URL of a Web App to be opened with additional data as specified in Initializing Web Apps
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/WebAppInfo" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
