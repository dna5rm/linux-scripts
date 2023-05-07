## createnewstickerset # Use this method to create a new sticker set owned by a user.
# https://core.telegram.org/bots/api#createnewstickerset

function createNewStickerSet ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to create a new sticker set owned by a user.
	Ref: https://core.telegram.org/bots/api#createnewstickerset
	---
	Use this method to create a new sticker set owned by a user. The bot
	will be able to edit the sticker set thus created. Returns *True* on
	success.
	
	  Parameter          Type                    Required   Description
	  ------------------ ----------------------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  user_id            Integer                 Yes        User identifier of created sticker set owner
	  name               String                  Yes        Short name of sticker set, to be used in `t.me/addstickers/` URLs (e.g., *animals*). Can contain only English letters, digits and underscores. Must begin with a letter, can't contain consecutive underscores and must end in `"_by_<bot_username>"`. `<bot_username>` is case insensitive. 1-64 characters.
	  title              String                  Yes        Sticker set title, 1-64 characters
	  stickers           Array of InputSticker   Yes        A JSON-serialized list of 1-50 initial stickers to be added to the sticker set
	  sticker_format     String                  Yes        Format of stickers in the set, must be one of "static", "animated", "video"
	  sticker_type       String                  Optional   Type of stickers in the set, pass "regular", "mask", or "custom_emoji". By default, a regular sticker set is created.
	  needs_repainting   Boolean                 Optional   Pass *True* if stickers in the sticker set must be repainted to the color of text when used in messages, the accent color if used as emoji status, white on chat photos, or another appropriate color based on context; for custom emoji sticker sets only
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/createNewStickerSet" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
