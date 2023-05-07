## setcustomemojistickersetthumbnail # Use this method to set the thumbnail of a custom emoji sticker set.
# https://core.telegram.org/bots/api#setcustomemojistickersetthumbnail

function setCustomEmojiStickerSetThumbnail ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to set the thumbnail of a custom emoji sticker set.
	Ref: https://core.telegram.org/bots/api#setcustomemojistickersetthumbnail
	---
	Use this method to set the thumbnail of a custom emoji sticker set.
	Returns *True* on success.
	
	  Parameter         Type     Required   Description
	  ----------------- -------- ---------- ---------------------------------------------------------------------------------------------------------------------------------------------------
	  name              String   Yes        Sticker set name
	  custom_emoji_id   String   Optional   Custom emoji identifier of a sticker from the sticker set; pass an empty string to drop the thumbnail and use the first sticker as the thumbnail.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setCustomEmojiStickerSetThumbnail" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
