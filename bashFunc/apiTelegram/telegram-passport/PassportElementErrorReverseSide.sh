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

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "$(grep -E "+{*}+" <<<${1:-{\}} 2> /dev/null)" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue with the reverse side of a document.
	Ref: https://core.telegram.org/bots/api#passportelementerrorreverseside
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents an issue with the reverse side of a document. The error is
considered resolved when the file with reverse side of the document
changes.
  Field       Type     Description
  ----------- -------- ------------------------------------------------------------------------------------------------------------
  source      String   Error source, must be *reverse_side*
  type        String   The section of the user\'s Telegram Passport which has the issue, one of "driver_license", "identity_card"
  file_hash   String   Base64-encoded hash of the file with the reverse side of the document
  message     String   Error message
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorReverseSide\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
