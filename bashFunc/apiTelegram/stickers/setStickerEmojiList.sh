## setstickeremojilist # Use this method to change the list of emoji assigned to a regular or custom emoji sticker.
# https://core.telegram.org/bots/api#setstickeremojilist

function setStickerEmojiList ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the list of emoji assigned to a regular or custom emoji sticker.
	Ref: https://core.telegram.org/bots/api#setstickeremojilist
	---
	Use this method to change the list of emoji assigned to a regular or
	custom emoji sticker. The sticker must belong to a sticker set created
	by the bot. Returns *True* on success.
	
	  Parameter    Type              Required   Description
	  ------------ ----------------- ---------- ------------------------------------------------------------------
	  sticker      String            Yes        File identifier of the sticker
	  emoji_list   Array of String   Yes        A JSON-serialized list of 1-20 emoji associated with the sticker
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setStickerEmojiList" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
