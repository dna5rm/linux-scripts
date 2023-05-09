## passportelementerrordatafield # Represents an issue in one of the data fields that was provided by the user.
# https://core.telegram.org/bots/api#passportelementerrordatafield

function PassportElementErrorDataField ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue in one of the data fields that was provided by the user.
	Ref: https://core.telegram.org/bots/api#passportelementerrordatafield
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents an issue in one of the data fields that was provided by the
user. The error is considered resolved when the field\'s value changes.
  Field        Type     Description
  ------------ -------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  source       String   Error source, must be *data*
  type         String   The section of the user\'s Telegram Passport which has the error, one of "personal_details", "passport", "driver_license", "identity_card", "internal_passport", "address"
  field_name   String   Name of the data field which has the error
  data_hash    String   Base64-encoded data hash
  message      String   Error message
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorDataField\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
