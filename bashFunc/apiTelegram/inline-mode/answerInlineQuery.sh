## answerinlinequery # Use this method to send answers to an inline query.
# https://core.telegram.org/bots/api#answerinlinequery

function answerInlineQuery ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send answers to an inline query.
	Ref: https://core.telegram.org/bots/api#answerinlinequery
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to send answers to an inline query. On success, *True*
is returned.\
No more than **50** results per query are allowed.
  Parameter         Type                         Required   Description
  ----------------- ---------------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  inline_query_id   String                       Yes        Unique identifier for the answered query
  results           Array of InlineQueryResult   Yes        A JSON-serialized array of results for the inline query
  cache_time        Integer                      Optional   The maximum amount of time in seconds that the result of the inline query may be cached on the server. Defaults to 300.
  is_personal       Boolean                      Optional   Pass *True* if results may be cached on the server side only for the user that sent the query. By default, results may be returned to any user who sends the same query.
  next_offset       String                       Optional   Pass the offset that a client should send in the next query with the same text to receive more results. Pass an empty string if there are no more results or if you don\'t support pagination. Offset length can\'t exceed 64 bytes.
  button            InlineQueryResultsButton     Optional   A JSON-serialized object describing a button to be shown above inline query results
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/answerInlineQuery" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
