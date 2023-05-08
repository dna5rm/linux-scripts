## editmessagetext # Use this method to edit text and game messages.
# https://core.telegram.org/bots/api#editmessagetext

function editMessageText ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to edit text and game messages.
	Ref: https://core.telegram.org/bots/api#editmessagetext
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to edit text and game messages. On success, if the
edited message is not an inline message, the edited Message is returned,
otherwise *True* is returned.
  Parameter                  Type                     Required   Description
  -------------------------- ------------------------ ---------- --------------------------------------------------------------------------------------------------------------------------------------------------------------
  chat_id                    Integer or String        Optional   Required if *inline_message_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
  message_id                 Integer                  Optional   Required if *inline_message_id* is not specified. Identifier of the message to edit
  inline_message_id          String                   Optional   Required if *chat_id* and *message_id* are not specified. Identifier of the inline message
  text                       String                   Yes        New text of the message, 1-4096 characters after entities parsing
  parse_mode                 String                   Optional   Mode for parsing entities in the message text. See formatting options for more details.
  entities                   Array of MessageEntity   Optional   A JSON-serialized list of special entities that appear in message text, which can be specified instead of *parse_mode*
  disable_web_page_preview   Boolean                  Optional   Disables link previews for links in this message
  reply_markup               InlineKeyboardMarkup     Optional   A JSON-serialized object for an inline keyboard.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/editMessageText" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
