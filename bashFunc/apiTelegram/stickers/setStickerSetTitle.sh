## setstickersettitle # Use this method to set the title of a created sticker set.
# https://core.telegram.org/bots/api#setstickersettitle

function setStickerSetTitle ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to set the title of a created sticker set.
	Ref: https://core.telegram.org/bots/api#setstickersettitle
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to set the title of a created sticker set. Returns
	*True* on success.
	
	  Parameter   Type     Required   Description
	  ----------- -------- ---------- ------------------------------------
	  name        String   Yes        Sticker set name
	  title       String   Yes        Sticker set title, 1-64 characters
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setStickerSetTitle" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
