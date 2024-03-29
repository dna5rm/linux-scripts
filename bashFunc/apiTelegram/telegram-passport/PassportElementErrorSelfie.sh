## passportelementerrorselfie # Represents an issue with the selfie with a document.
# https://core.telegram.org/bots/api#passportelementerrorselfie

function PassportElementErrorSelfie ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue with the selfie with a document.
	Ref: https://core.telegram.org/bots/api#passportelementerrorselfie
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents an issue with the selfie with a document. The error is
considered resolved when the file with the selfie changes.
  Field       Type     Description
  ----------- -------- ---------------------------------------------------------------------------------------------------------------------------------------------
  source      String   Error source, must be *selfie*
  type        String   The section of the user\'s Telegram Passport which has the issue, one of "passport", "driver_license", "identity_card", "internal_passport"
  file_hash   String   Base64-encoded hash of the file with the selfie
  message     String   Error message
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorSelfie\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
