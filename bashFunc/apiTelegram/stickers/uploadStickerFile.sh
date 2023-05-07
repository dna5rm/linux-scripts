## uploadstickerfile # Use this method to upload a file with a sticker for later use in the createNewStickerSet and addStickerToSet methods (the file can be used multiple times).
# https://core.telegram.org/bots/api#uploadstickerfile

function uploadStickerFile ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to upload a file with a sticker for later use in the createNewStickerSet and addStickerToSet methods (the file can be used multiple times).
	Ref: https://core.telegram.org/bots/api#uploadstickerfile
	---
	Use this method to upload a file with a sticker for later use in the
	createNewStickerSet and addStickerToSet methods (the file can be used
	multiple times). Returns the uploaded File on success.
	
	  Parameter        Type        Required   Description
	  ---------------- ----------- ---------- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  user_id          Integer     Yes        User identifier of sticker file owner
	  sticker          InputFile   Yes        A file with the sticker in .WEBP, .PNG, .TGS, or .WEBM format. See https://core.telegram.org/stickers for technical requirements. More information on Sending Files »
	  sticker_format   String      Yes        Format of the sticker, must be one of "static", "animated", "video"
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/uploadStickerFile" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
