## stickerset # This object represents a sticker set.
# https://core.telegram.org/bots/api#stickerset

function StickerSet ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a sticker set.
	Ref: https://core.telegram.org/bots/api#stickerset
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a sticker set.
  Field          Type               Description
  -------------- ------------------ ---------------------------------------------------------------------------------
  name           String             Sticker set name
  title          String             Sticker set title
  sticker_type   String             Type of stickers in the set, currently one of "regular", "mask", "custom_emoji"
  is_animated    Boolean            *True*, if the sticker set contains animated stickers
  is_video       Boolean            *True*, if the sticker set contains video stickers
  stickers       Array of Sticker   List of all set stickers
  thumbnail      PhotoSize          *Optional*. Sticker set thumbnail in the .WEBP, .TGS, or .WEBM format
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/StickerSet\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
