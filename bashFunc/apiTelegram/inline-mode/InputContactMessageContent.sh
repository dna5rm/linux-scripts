## inputcontactmessagecontent # Represents the content of a contact message to be sent as the result of an inline query.
# https://core.telegram.org/bots/api#inputcontactmessagecontent

function InputContactMessageContent ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents the content of a contact message to be sent as the result of an inline query.
	Ref: https://core.telegram.org/bots/api#inputcontactmessagecontent
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents the content of a contact message to be sent as the result of
an inline query.
  Field          Type     Description
  -------------- -------- ------------------------------------------------------------------------------------
  phone_number   String   Contact\'s phone number
  first_name     String   Contact\'s first name
  last_name      String   *Optional*. Contact\'s last name
  vcard          String   *Optional*. Additional data about the contact in the form of a vCard, 0-2048 bytes
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputContactMessageContent\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
