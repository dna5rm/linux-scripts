## setchatstickerset # Use this method to set a new group sticker set for a supergroup.
# https://core.telegram.org/bots/api#setchatstickerset

function setChatStickerSet ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to set a new group sticker set for a supergroup.
	Ref: https://core.telegram.org/bots/api#setchatstickerset
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to set a new group sticker set for a supergroup. The bot
must be an administrator in the chat for this to work and must have the
appropriate administrator rights. Use the field *can_set_sticker_set*
optionally returned in getChat requests to check if the bot can use this
method. Returns *True* on success.
  Parameter          Type                Required   Description
  ------------------ ------------------- ---------- ------------------------------------------------------------------------------------------------------------------
  chat_id            Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
  sticker_set_name   String              Yes        Name of the sticker set to be set as the group sticker set
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setChatStickerSet\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
