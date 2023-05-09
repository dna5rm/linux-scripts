## passportelementerror # This object represents an error in the Telegram Passport element which was submitted that should be resolved by the user.
# https://core.telegram.org/bots/api#passportelementerror

function PassportElementError ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an error in the Telegram Passport element which was submitted that should be resolved by the user.
	Ref: https://core.telegram.org/bots/api#passportelementerror
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents an error in the Telegram Passport element which
was submitted that should be resolved by the user. It should be one of:
-   PassportElementErrorDataField
-   PassportElementErrorFrontSide
-   PassportElementErrorReverseSide
-   PassportElementErrorSelfie
-   PassportElementErrorFile
-   PassportElementErrorFiles
-   PassportElementErrorTranslationFile
-   PassportElementErrorTranslationFiles
-   PassportElementErrorUnspecified
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementError\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
