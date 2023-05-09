## inputsticker # This object describes a sticker to be added to a sticker set.
# https://core.telegram.org/bots/api#inputsticker

function InputSticker ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object describes a sticker to be added to a sticker set.
	Ref: https://core.telegram.org/bots/api#inputsticker
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object describes a sticker to be added to a sticker set.
  Field           Type                  Description
  --------------- --------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  sticker         InputFile or String   The added sticker. Pass a *file_id* as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, upload a new one using multipart/form-data, or pass "attach://\<file_attach_name\>" to upload a new one using multipart/form-data under \<file_attach_name\> name. Animated and video stickers can\'t be uploaded via HTTP URL. More information on Sending Files »
  emoji_list      Array of String       List of 1-20 emoji associated with the sticker
  mask_position   MaskPosition          *Optional*. Position where the mask should be placed on faces. For "mask" stickers only.
  keywords        Array of String       *Optional*. List of 0-20 search keywords for the sticker with total length of up to 64 characters. For "regular" and "custom_emoji" stickers only.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputSticker\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
