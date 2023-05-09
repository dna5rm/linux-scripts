## passportdata # Describes Telegram Passport data shared with the bot by the user.
# https://core.telegram.org/bots/api#passportdata

function PassportData ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Describes Telegram Passport data shared with the bot by the user.
	Ref: https://core.telegram.org/bots/api#passportdata
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Describes Telegram Passport data shared with the bot by the user.
  Field         Type                                Description
  ------------- ----------------------------------- ----------------------------------------------------------------------------------------------------------
  data          Array of EncryptedPassportElement   Array with information about documents and other Telegram Passport elements that was shared with the bot
  credentials   EncryptedCredentials                Encrypted credentials required to decrypt the data
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportData\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
