## getstickerset # Use this method to get a sticker set.
# https://core.telegram.org/bots/api#getstickerset

function getStickerSet ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get a sticker set.
	Ref: https://core.telegram.org/bots/api#getstickerset
	---
	Use this method to get a sticker set. On success, a StickerSet object is
	returned.
	
	  Parameter   Type     Required   Description
	  ----------- -------- ---------- -------------------------
	  name        String   Yes        Name of the sticker set
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getStickerSet" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
