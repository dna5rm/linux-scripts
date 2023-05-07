## passportelementerrorreverseside # Represents an issue with the reverse side of a document.
# https://core.telegram.org/bots/api#passportelementerrorreverseside

function PassportElementErrorReverseSide ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue with the reverse side of a document.
	Ref: https://core.telegram.org/bots/api#passportelementerrorreverseside
	---
	Represents an issue with the reverse side of a document. The error is
	considered resolved when the file with reverse side of the document
	changes.
	
	  Field       Type     Description
	  ----------- -------- ------------------------------------------------------------------------------------------------------------
	  source      String   Error source, must be *reverse_side*
	  type        String   The section of the user's Telegram Passport which has the issue, one of "driver_license", "identity_card"
	  file_hash   String   Base64-encoded hash of the file with the reverse side of the document
	  message     String   Error message
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorReverseSide" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
