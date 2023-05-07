## keyboardbuttonrequestchat # This object defines the criteria used to request a suitable chat.
# https://core.telegram.org/bots/api#keyboardbuttonrequestchat

function KeyboardButtonRequestChat ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object defines the criteria used to request a suitable chat.
	Ref: https://core.telegram.org/bots/api#keyboardbuttonrequestchat
	---
	This object defines the criteria used to request a suitable chat. The
	identifier of the selected chat will be shared with the bot when the
	corresponding button is pressed. More about requesting chats »
	
	  Field                       Type                      Description
	  --------------------------- ------------------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  request_id                  Integer                   Signed 32-bit identifier of the request, which will be received back in the ChatShared object. Must be unique within the message
	  chat_is_channel             Boolean                   Pass *True* to request a channel chat, pass *False* to request a group or a supergroup chat.
	  chat_is_forum               Boolean                   *Optional*. Pass *True* to request a forum supergroup, pass *False* to request a non-forum chat. If not specified, no additional restrictions are applied.
	  chat_has_username           Boolean                   *Optional*. Pass *True* to request a supergroup or a channel with a username, pass *False* to request a chat without a username. If not specified, no additional restrictions are applied.
	  chat_is_created             Boolean                   *Optional*. Pass *True* to request a chat owned by the user. Otherwise, no additional restrictions are applied.
	  user_administrator_rights   ChatAdministratorRights   *Optional*. A JSON-serialized object listing the required administrator rights of the user in the chat. The rights must be a superset of *bot_administrator_rights*. If not specified, no additional restrictions are applied.
	  bot_administrator_rights    ChatAdministratorRights   *Optional*. A JSON-serialized object listing the required administrator rights of the bot in the chat. The rights must be a subset of *user_administrator_rights*. If not specified, no additional restrictions are applied.
	  bot_is_member               Boolean                   *Optional*. Pass *True* to request a chat with the bot as a member. Otherwise, no additional restrictions are applied.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/KeyboardButtonRequestChat" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
