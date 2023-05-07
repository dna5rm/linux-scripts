## game # This object represents a game.
# https://core.telegram.org/bots/api#game

function Game ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a game.
	Ref: https://core.telegram.org/bots/api#game
	---
	This object represents a game. Use BotFather to create and edit games,
	their short names will act as unique identifiers.
	
	  Field           Type                     Description
	  --------------- ------------------------ --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  title           String                   Title of the game
	  description     String                   Description of the game
	  photo           Array of PhotoSize       Photo that will be displayed in the game message in chats.
	  text            String                   *Optional*. Brief description of the game or high scores included in the game message. Can be automatically edited to include current high scores for the game when the bot calls setGameScore, or manually edited using editMessageText. 0-4096 characters.
	  text_entities   Array of MessageEntity   *Optional*. Special entities that appear in *text*, such as usernames, URLs, bot commands, etc.
	  animation       Animation                *Optional*. Animation that will be displayed in the game message in chats. Upload via BotFather
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/Game" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
