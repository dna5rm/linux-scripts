## passportdata # Describes Telegram Passport data shared with the bot by the user.
# https://core.telegram.org/bots/api#passportdata

function PassportData ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Describes Telegram Passport data shared with the bot by the user.
	Ref: https://core.telegram.org/bots/api#passportdata
	---
	Describes Telegram Passport data shared with the bot by the user.
	
	  Field         Type                                Description
	  ------------- ----------------------------------- ----------------------------------------------------------------------------------------------------------
	  data          Array of EncryptedPassportElement   Array with information about documents and other Telegram Passport elements that was shared with the bot
	  credentials   EncryptedCredentials                Encrypted credentials required to decrypt the data
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportData" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
