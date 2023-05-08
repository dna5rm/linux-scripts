## pollanswer # This object represents an answer of a user in a non-anonymous poll.
# https://core.telegram.org/bots/api#pollanswer

function PollAnswer ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an answer of a user in a non-anonymous poll.
	Ref: https://core.telegram.org/bots/api#pollanswer
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents an answer of a user in a non-anonymous poll.
  Field        Type               Description
  ------------ ------------------ -----------------------------------------------------------------------------------------------------------
  poll_id      String             Unique poll identifier
  user         User               The user, who changed the answer to the poll
  option_ids   Array of Integer   0-based identifiers of answer options, chosen by the user. May be empty if the user retracted their vote.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PollAnswer" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
