## passportelementerrortranslationfiles # Represents an issue with the translated version of a document.
# https://core.telegram.org/bots/api#passportelementerrortranslationfiles

function PassportElementErrorTranslationFiles ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue with the translated version of a document.
	Ref: https://core.telegram.org/bots/api#passportelementerrortranslationfiles
	---
	Represents an issue with the translated version of a document. The error
	is considered resolved when a file with the document translation change.
	
	  Field         Type              Description
	  ------------- ----------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  source        String            Error source, must be *translation_files*
	  type          String            Type of element of the user's Telegram Passport which has the issue, one of "passport", "driver_license", "identity_card", "internal_passport", "utility_bill", "bank_statement", "rental_agreement", "passport_registration", "temporary_registration"
	  file_hashes   Array of String   List of base64-encoded file hashes
	  message       String            Error message
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorTranslationFiles" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
