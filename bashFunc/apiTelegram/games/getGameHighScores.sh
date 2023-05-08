## getgamehighscores # Use this method to get data for high score tables.
# https://core.telegram.org/bots/api#getgamehighscores

function getGameHighScores ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get data for high score tables.
	Ref: https://core.telegram.org/bots/api#getgamehighscores
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to get data for high score tables. Will return the score
of the specified user and several of their neighbors in a game. Returns
an Array of GameHighScore objects.
> This method will currently return scores for the target user, plus two
> of their closest neighbors on each side. Will also return the top
> three users if the user and their neighbors are not among them. Please
> note that this behavior is subject to change.
  Parameter           Type      Required   Description
  ------------------- --------- ---------- --------------------------------------------------------------------------------------------
  user_id             Integer   Yes        Target user id
  chat_id             Integer   Optional   Required if *inline_message_id* is not specified. Unique identifier for the target chat
  message_id          Integer   Optional   Required if *inline_message_id* is not specified. Identifier of the sent message
  inline_message_id   String    Optional   Required if *chat_id* and *message_id* are not specified. Identifier of the inline message
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getGameHighScores" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
