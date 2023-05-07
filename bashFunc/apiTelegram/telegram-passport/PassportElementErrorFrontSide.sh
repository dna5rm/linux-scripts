## passportelementerrorfrontside # Represents an issue with the front side of a document.
# https://core.telegram.org/bots/api#passportelementerrorfrontside

function PassportElementErrorFrontSide ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue with the front side of a document.
	Ref: https://core.telegram.org/bots/api#passportelementerrorfrontside
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents an issue with the front side of a document. The error is
	considered resolved when the file with the front side of the document
	changes.
	
	  Field       Type     Description
	  ----------- -------- ---------------------------------------------------------------------------------------------------------------------------------------------
	  source      String   Error source, must be *front_side*
	  type        String   The section of the user's Telegram Passport which has the issue, one of "passport", "driver_license", "identity_card", "internal_passport"
	  file_hash   String   Base64-encoded hash of the file with the front side of the document
	  message     String   Error message
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorFrontSide" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
