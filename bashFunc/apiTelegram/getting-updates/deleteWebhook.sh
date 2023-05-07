## deletewebhook # Use this method to remove webhook integration if you decide to switch back to getUpdates.
# https://core.telegram.org/bots/api#deletewebhook

function deleteWebhook ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to remove webhook integration if you decide to switch back to getUpdates.
	Ref: https://core.telegram.org/bots/api#deletewebhook
	---
	Use this method to remove webhook integration if you decide to switch
	back to getUpdates. Returns *True* on success.
	
	  Parameter              Type      Required   Description
	  ---------------------- --------- ---------- -----------------------------------------
	  drop_pending_updates   Boolean   Optional   Pass *True* to drop all pending updates
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/deleteWebhook" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
