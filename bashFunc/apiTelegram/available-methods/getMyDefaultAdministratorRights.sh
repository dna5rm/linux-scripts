## getmydefaultadministratorrights # Use this method to get the current default administrator rights of the bot.
# https://core.telegram.org/bots/api#getmydefaultadministratorrights

function getMyDefaultAdministratorRights ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get the current default administrator rights of the bot.
	Ref: https://core.telegram.org/bots/api#getmydefaultadministratorrights
	---
	Use this method to get the current default administrator rights of the
	bot. Returns ChatAdministratorRights on success.
	
	  Parameter      Type      Required   Description
	  -------------- --------- ---------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  for_channels   Boolean   Optional   Pass *True* to get default administrator rights of the bot in channels. Otherwise, default administrator rights of the bot for groups and supergroups will be returned.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getMyDefaultAdministratorRights" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
