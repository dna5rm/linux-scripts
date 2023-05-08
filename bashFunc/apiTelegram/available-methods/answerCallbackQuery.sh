## answercallbackquery # Use this method to send answers to callback queries sent from inline keyboards.
# https://core.telegram.org/bots/api#answercallbackquery

function answerCallbackQuery ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send answers to callback queries sent from inline keyboards.
	Ref: https://core.telegram.org/bots/api#answercallbackquery
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to send answers to callback queries sent from inline
keyboards. The answer will be displayed to the user as a notification at
the top of the chat screen or as an alert. On success, *True* is
returned.
> Alternatively, the user can be redirected to the specified Game URL.
> For this option to work, you must first create a game for your bot via
> \@BotFather and accept the terms. Otherwise, you may use links like
> `t.me/your_bot?start=XXXX` that open your bot with a parameter.
  ------------------------------------------------------------------------------------
  Parameter           Type              Required          Description
  ------------------- ----------------- ----------------- ----------------------------
  callback_query_id   String            Yes               Unique identifier for the
                                                          query to be answered
  text                String            Optional          Text of the notification. If
                                                          not specified, nothing will
                                                          be shown to the user, 0-200
                                                          characters
  show_alert          Boolean           Optional          If *True*, an alert will be
                                                          shown by the client instead
                                                          of a notification at the top
                                                          of the chat screen. Defaults
                                                          to *false*.
  url                 String            Optional          URL that will be opened by
                                                          the user\'s client. If you
                                                          have created a Game and
                                                          accepted the conditions via
                                                          \@BotFather, specify the URL
                                                          that opens your game - note
                                                          that this will only work if
                                                          the query comes from a
                                                          *callback_game* button.\
                                                          \
                                                          Otherwise, you may use links
                                                          like
                                                          `t.me/your_bot?start=XXXX`
                                                          that open your bot with a
                                                          parameter.
  cache_time          Integer           Optional          The maximum amount of time
                                                          in seconds that the result
                                                          of the callback query may be
                                                          cached client-side. Telegram
                                                          apps will support caching
                                                          starting in version 3.14.
                                                          Defaults to 0.
  ------------------------------------------------------------------------------------
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/answerCallbackQuery" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
