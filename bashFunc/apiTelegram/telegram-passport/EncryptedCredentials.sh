## encryptedcredentials # Describes data required for decrypting and authenticating EncryptedPassportElement.
# https://core.telegram.org/bots/api#encryptedcredentials

function EncryptedCredentials ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Describes data required for decrypting and authenticating EncryptedPassportElement.
	Ref: https://core.telegram.org/bots/api#encryptedcredentials
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Describes data required for decrypting and authenticating
EncryptedPassportElement. See the Telegram Passport Documentation for a
complete description of the data decryption and authentication
processes.
  Field    Type     Description
  -------- -------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  data     String   Base64-encoded encrypted JSON-serialized data with unique user\'s payload, data hashes and secrets required for EncryptedPassportElement decryption and authentication
  hash     String   Base64-encoded data hash for data authentication
  secret   String   Base64-encoded secret, encrypted with the bot\'s public RSA key, required for data decryption
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/EncryptedCredentials\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
