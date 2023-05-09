## inlinequeryresultgame # Represents a Game.
# https://core.telegram.org/bots/api#inlinequeryresultgame

function InlineQueryResultGame ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a Game.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultgame
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents a Game.
  Field             Type                   Description
  ----------------- ---------------------- -----------------------------------------------------
  type              String                 Type of the result, must be *game*
  id                String                 Unique identifier for this result, 1-64 bytes
  game_short_name   String                 Short name of the game
  reply_markup      InlineKeyboardMarkup   *Optional*. Inline keyboard attached to the message
**Note:** This will only work in Telegram versions released after
October 1, 2016. Older clients will not display any inline results if a
game result is among them.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultGame\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
