## setpassportdataerrors # Informs a user that some of the Telegram Passport elements they provided contains errors.
# https://core.telegram.org/bots/api#setpassportdataerrors

function setPassportDataErrors ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Informs a user that some of the Telegram Passport elements they provided contains errors.
	Ref: https://core.telegram.org/bots/api#setpassportdataerrors
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Informs a user that some of the Telegram Passport elements they provided
contains errors. The user will not be able to re-submit their Passport
to you until the errors are fixed (the contents of the field for which
you returned the error must change). Returns *True* on success.
Use this if the data submitted by the user doesn\'t satisfy the
standards your service requires for any reason. For example, if a
birthday date seems invalid, a submitted document is blurry, a scan
shows evidence of tampering, etc. Supply some details in the error
message to make sure the user knows how to correct the issues.
  Parameter   Type                            Required   Description
  ----------- ------------------------------- ---------- -----------------------------------------------
  user_id     Integer                         Yes        User identifier
  errors      Array of PassportElementError   Yes        A JSON-serialized array describing the errors
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setPassportDataErrors\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
