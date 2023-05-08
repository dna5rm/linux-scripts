## inlinequeryresultsbutton # This object represents a button to be shown above inline query results.
# https://core.telegram.org/bots/api#inlinequeryresultsbutton

function InlineQueryResultsButton ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a button to be shown above inline query results.
	Ref: https://core.telegram.org/bots/api#inlinequeryresultsbutton
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a button to be shown above inline query results.
You **must** use exactly one of the optional fields.
  -----------------------------------------------------------------------
  Field                   Type                    Description
  ----------------------- ----------------------- -----------------------
  text                    String                  Label text on the
                                                  button
  web_app                 WebAppInfo              *Optional*. Description
                                                  of the Web App that
                                                  will be launched when
                                                  the user presses the
                                                  button. The Web App
                                                  will be able to switch
                                                  back to the inline mode
                                                  using the method
                                                  switchInlineQuery
                                                  inside the Web App.
  start_parameter         String                  *Optional*.
                                                  Deep-linking parameter
                                                  for the /start message
                                                  sent to the bot when a
                                                  user presses the
                                                  button. 1-64
                                                  characters, only `A-Z`,
                                                  `a-z`, `0-9`, `_` and
                                                  `-` are allowed.\
                                                  \
                                                  *Example:* An inline
                                                  bot that sends YouTube
                                                  videos can ask the user
                                                  to connect the bot to
                                                  their YouTube account
                                                  to adapt search results
                                                  accordingly. To do
                                                  this, it displays a
                                                  \'Connect your YouTube
                                                  account\' button above
                                                  the results, or even
                                                  before showing any. The
                                                  user presses the
                                                  button, switches to a
                                                  private chat with the
                                                  bot and, in doing so,
                                                  passes a start
                                                  parameter that
                                                  instructs the bot to
                                                  return an OAuth link.
                                                  Once done, the bot can
                                                  offer a *switch_inline*
                                                  button so that the user
                                                  can easily return to
                                                  the chat where they
                                                  wanted to use the
                                                  bot\'s inline
                                                  capabilities.
  -----------------------------------------------------------------------
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResultsButton" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
