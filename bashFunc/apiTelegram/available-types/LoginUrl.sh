## loginurl # This object represents a parameter of the inline keyboard button used to automatically authorize a user.
# https://core.telegram.org/bots/api#loginurl

function LoginUrl ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a parameter of the inline keyboard button used to automatically authorize a user.
	Ref: https://core.telegram.org/bots/api#loginurl
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a parameter of the inline keyboard button used to
automatically authorize a user. Serves as a great replacement for the
Telegram Login Widget when the user is coming from Telegram. All the
user needs to do is tap/click a button and confirm that they want to log
in:
::: blog_image_wrap
:::
Telegram apps support these buttons as of version 5.7.
> Sample bot: \@discussbot
  -----------------------------------------------------------------------
  Field                   Type                    Description
  ----------------------- ----------------------- -----------------------
  url                     String                  An HTTPS URL to be
                                                  opened with user
                                                  authorization data
                                                  added to the query
                                                  string when the button
                                                  is pressed. If the user
                                                  refuses to provide
                                                  authorization data, the
                                                  original URL without
                                                  information about the
                                                  user will be opened.
                                                  The data added is the
                                                  same as described in
                                                  Receiving authorization
                                                  data.\
                                                  \
                                                  **NOTE:** You **must**
                                                  always check the hash
                                                  of the received data to
                                                  verify the
                                                  authentication and the
                                                  integrity of the data
                                                  as described in
                                                  Checking authorization.
  forward_text            String                  *Optional*. New text of
                                                  the button in forwarded
                                                  messages.
  bot_username            String                  *Optional*. Username of
                                                  a bot, which will be
                                                  used for user
                                                  authorization. See
                                                  Setting up a bot for
                                                  more details. If not
                                                  specified, the current
                                                  bot\'s username will be
                                                  assumed. The *url*\'s
                                                  domain must be the same
                                                  as the domain linked
                                                  with the bot. See
                                                  Linking your domain to
                                                  the bot for more
                                                  details.
  request_write_access    Boolean                 *Optional*. Pass *True*
                                                  to request the
                                                  permission for your bot
                                                  to send messages to the
                                                  user.
  -----------------------------------------------------------------------
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/LoginUrl" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
