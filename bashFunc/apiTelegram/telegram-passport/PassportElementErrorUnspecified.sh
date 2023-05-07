## passportelementerrorunspecified # Represents an issue in an unspecified place.
# https://core.telegram.org/bots/api#passportelementerrorunspecified

function PassportElementErrorUnspecified ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an issue in an unspecified place.
	Ref: https://core.telegram.org/bots/api#passportelementerrorunspecified
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Represents an issue in an unspecified place. The error is considered
	resolved when new data is added.
	
	  Field          Type     Description
	  -------------- -------- ----------------------------------------------------------------------
	  source         String   Error source, must be *unspecified*
	  type           String   Type of element of the user's Telegram Passport which has the issue
	  element_hash   String   Base64-encoded element hash
	  message        String   Error message
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PassportElementErrorUnspecified" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
