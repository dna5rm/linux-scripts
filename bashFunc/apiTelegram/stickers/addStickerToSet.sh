## addstickertoset # Use this method to add a new sticker to a set created by the bot.
# https://core.telegram.org/bots/api#addstickertoset

function addStickerToSet ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to add a new sticker to a set created by the bot.
	Ref: https://core.telegram.org/bots/api#addstickertoset
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to add a new sticker to a set created by the bot. The
	format of the added sticker must match the format of the other stickers
	in the set. Emoji sticker sets can have up to 200 stickers. Animated and
	video sticker sets can have up to 50 stickers. Static sticker sets can
	have up to 120 stickers. Returns *True* on success.
	
	  Parameter   Type           Required   Description
	  ----------- -------------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
	  user_id     Integer        Yes        User identifier of sticker set owner
	  name        String         Yes        Sticker set name
	  sticker     InputSticker   Yes        A JSON-serialized object with information about the added sticker. If exactly the same sticker had already been added to the set, then the set isn't changed.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/addStickerToSet" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
