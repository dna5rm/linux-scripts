## setstickerpositioninset # Use this method to move a sticker in a set created by the bot to a specific position.
# https://core.telegram.org/bots/api#setstickerpositioninset

function setStickerPositionInSet ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to move a sticker in a set created by the bot to a specific position.
	Ref: https://core.telegram.org/bots/api#setstickerpositioninset
	---
	Use this method to move a sticker in a set created by the bot to a
	specific position. Returns *True* on success.
	
	  Parameter   Type      Required   Description
	  ----------- --------- ---------- ---------------------------------------------
	  sticker     String    Yes        File identifier of the sticker
	  position    Integer   Yes        New sticker position in the set, zero-based
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setStickerPositionInSet" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
