## gamehighscore # This object represents one row of the high scores table for a game.
# https://core.telegram.org/bots/api#gamehighscore

function GameHighScore ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents one row of the high scores table for a game.
	Ref: https://core.telegram.org/bots/api#gamehighscore
	---
	This object represents one row of the high scores table for a game.
	
	  Field      Type      Description
	  ---------- --------- -------------------------------------------
	  position   Integer   Position in high score table for the game
	  user       User      User
	  score      Integer   Score
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/GameHighScore" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
