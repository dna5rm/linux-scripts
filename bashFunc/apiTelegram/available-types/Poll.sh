## poll # This object contains information about a poll.
# https://core.telegram.org/bots/api#poll

function Poll ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object contains information about a poll.
	Ref: https://core.telegram.org/bots/api#poll
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object contains information about a poll.
  Field                     Type                     Description
  ------------------------- ------------------------ -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  id                        String                   Unique poll identifier
  question                  String                   Poll question, 1-300 characters
  options                   Array of PollOption      List of poll options
  total_voter_count         Integer                  Total number of users that voted in the poll
  is_closed                 Boolean                  *True*, if the poll is closed
  is_anonymous              Boolean                  *True*, if the poll is anonymous
  type                      String                   Poll type, currently can be "regular" or "quiz"
  allows_multiple_answers   Boolean                  *True*, if the poll allows multiple answers
  correct_option_id         Integer                  *Optional*. 0-based identifier of the correct answer option. Available only for polls in the quiz mode, which are closed, or was sent (not forwarded) by the bot or to the private chat with the bot.
  explanation               String                   *Optional*. Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters
  explanation_entities      Array of MessageEntity   *Optional*. Special entities like usernames, URLs, bot commands, etc. that appear in the *explanation*
  open_period               Integer                  *Optional*. Amount of time in seconds the poll will be active after creation
  close_date                Integer                  *Optional*. Point in time (Unix timestamp) when the poll will be automatically closed
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/Poll\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
