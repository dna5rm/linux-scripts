## setmydefaultadministratorrights # Use this method to change the default administrator rights requested by the bot when it's added as an administrator to groups or channels.
# https://core.telegram.org/bots/api#setmydefaultadministratorrights

function setMyDefaultAdministratorRights ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the default administrator rights requested by the bot when it's added as an administrator to groups or channels.
	Ref: https://core.telegram.org/bots/api#setmydefaultadministratorrights
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to change the default administrator rights requested by
the bot when it\'s added as an administrator to groups or channels.
These rights will be suggested to users, but they are free to modify the
list before adding the bot. Returns *True* on success.
  Parameter      Type                      Required   Description
  -------------- ------------------------- ---------- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  rights         ChatAdministratorRights   Optional   A JSON-serialized object describing new default administrator rights. If not specified, the default administrator rights will be cleared.
  for_channels   Boolean                   Optional   Pass *True* to change the default administrator rights of the bot in channels. Otherwise, the default administrator rights of the bot for groups and supergroups will be changed.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setMyDefaultAdministratorRights\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
