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

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an error in the Telegram Passport element which was submitted that should be resolved by the user.
	Ref: https://core.telegram.org/bots/api#passportelementerror
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
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementError" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
