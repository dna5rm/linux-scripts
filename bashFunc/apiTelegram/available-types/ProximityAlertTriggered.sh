## proximityalerttriggered # This object represents the content of a service message, sent whenever a user in the chat triggers a proximity alert set by another user.
# https://core.telegram.org/bots/api#proximityalerttriggered

function ProximityAlertTriggered ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents the content of a service message, sent whenever a user in the chat triggers a proximity alert set by another user.
	Ref: https://core.telegram.org/bots/api#proximityalerttriggered
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents the content of a service message, sent whenever a
user in the chat triggers a proximity alert set by another user.
  Field      Type      Description
  ---------- --------- --------------------------------
  traveler   User      User that triggered the alert
  watcher    User      User that set the alert
  distance   Integer   The distance between the users
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/ProximityAlertTriggered\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
