## setstickermaskposition # Use this method to change the mask position of a mask sticker.
# https://core.telegram.org/bots/api#setstickermaskposition

function setStickerMaskPosition ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the mask position of a mask sticker.
	Ref: https://core.telegram.org/bots/api#setstickermaskposition
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to change the mask position of a mask sticker. The
sticker must belong to a sticker set that was created by the bot.
Returns *True* on success.
  Parameter       Type           Required   Description
  --------------- -------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------
  sticker         String         Yes        File identifier of the sticker
  mask_position   MaskPosition   Optional   A JSON-serialized object with the position where the mask should be placed on faces. Omit the parameter to remove the mask position.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setStickerMaskPosition" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
