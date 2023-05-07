## botcommand # This object represents a bot command.
# https://core.telegram.org/bots/api#botcommand

function BotCommand ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a bot command.
	Ref: https://core.telegram.org/bots/api#botcommand
	---
	This object represents a bot command.
	
	  Field         Type     Description
	  ------------- -------- -----------------------------------------------------------------------------------------------------------
	  command       String   Text of the command; 1-32 characters. Can contain only lowercase English letters, digits and underscores.
	  description   String   Description of the command; 1-256 characters.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/BotCommand" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
