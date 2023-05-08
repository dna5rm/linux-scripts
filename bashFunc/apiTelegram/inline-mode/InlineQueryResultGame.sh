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
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultGame" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
