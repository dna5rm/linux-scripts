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

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "$(grep -E "+{*}+" <<<${1:-{\}} 2> /dev/null)" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to remove webhook integration if you decide to switch back to getUpdates.
	Ref: https://core.telegram.org/bots/api#deletewebhook
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to remove webhook integration if you decide to switch
back to getUpdates. Returns *True* on success.
  Parameter              Type      Required   Description
  ---------------------- --------- ---------- -----------------------------------------
  drop_pending_updates   Boolean   Optional   Pass *True* to drop all pending updates
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/deleteWebhook\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
