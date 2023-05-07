## passportelementerrorfiles # Represents an issue with a list of scans.
# https://core.telegram.org/bots/api#passportelementerrorfiles

function PassportElementErrorFiles ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue with a list of scans.
	Ref: https://core.telegram.org/bots/api#passportelementerrorfiles
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents an issue with a list of scans. The error is considered
	resolved when the list of files containing the scans changes.
	
	  Field         Type              Description
	  ------------- ----------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  source        String            Error source, must be *files*
	  type          String            The section of the user's Telegram Passport which has the issue, one of "utility_bill", "bank_statement", "rental_agreement", "passport_registration", "temporary_registration"
	  file_hashes   Array of String   List of base64-encoded file hashes
	  message       String            Error message
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorFiles" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
