## passportelementerrorfile # Represents an issue with a document scan.
# https://core.telegram.org/bots/api#passportelementerrorfile

function PassportElementErrorFile ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue with a document scan.
	Ref: https://core.telegram.org/bots/api#passportelementerrorfile
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents an issue with a document scan. The error is considered
	resolved when the file with the document scan changes.
	
	  Field       Type     Description
	  ----------- -------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  source      String   Error source, must be *file*
	  type        String   The section of the user's Telegram Passport which has the issue, one of "utility_bill", "bank_statement", "rental_agreement", "passport_registration", "temporary_registration"
	  file_hash   String   Base64-encoded file hash
	  message     String   Error message
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorFile" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
