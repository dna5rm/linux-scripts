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
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setStickerMaskPosition\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
