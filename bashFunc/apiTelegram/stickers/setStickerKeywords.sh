## setstickerkeywords # Use this method to change search keywords assigned to a regular or custom emoji sticker.
# https://core.telegram.org/bots/api#setstickerkeywords

function setStickerKeywords ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change search keywords assigned to a regular or custom emoji sticker.
	Ref: https://core.telegram.org/bots/api#setstickerkeywords
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to change search keywords assigned to a regular or
custom emoji sticker. The sticker must belong to a sticker set created
by the bot. Returns *True* on success.
  Parameter   Type              Required   Description
  ----------- ----------------- ---------- ---------------------------------------------------------------------------------------------------------
  sticker     String            Yes        File identifier of the sticker
  keywords    Array of String   Optional   A JSON-serialized list of 0-20 search keywords for the sticker with total length of up to 64 characters
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setStickerKeywords\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
