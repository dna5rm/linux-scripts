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
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/getCustomEmojiStickers\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
