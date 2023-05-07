## getcustomemojistickers # Use this method to get information about custom emoji stickers by their identifiers.
# https://core.telegram.org/bots/api#getcustomemojistickers

function getCustomEmojiStickers ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get information about custom emoji stickers by their identifiers.
	Ref: https://core.telegram.org/bots/api#getcustomemojistickers
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to get information about custom emoji stickers by their
	identifiers. Returns an Array of Sticker objects.
	
	  Parameter          Type              Required   Description
	  ------------------ ----------------- ---------- ------------------------------------------------------------------------------------------
	  custom_emoji_ids   Array of String   Yes        List of custom emoji identifiers. At most 200 custom emoji identifiers can be specified.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getCustomEmojiStickers" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
