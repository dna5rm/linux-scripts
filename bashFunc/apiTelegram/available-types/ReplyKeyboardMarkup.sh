## replykeyboardmarkup # This object represents a custom keyboard with reply options (see Introduction to bots for details and examples).
# https://core.telegram.org/bots/api#replykeyboardmarkup

function ReplyKeyboardMarkup ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a custom keyboard with reply options (see Introduction to bots for details and examples).
	Ref: https://core.telegram.org/bots/api#replykeyboardmarkup
	---
	This object represents a custom keyboard with reply options (see
	Introduction to bots for details and examples).
	
	  ---------------------------------------------------------------------------
	  Field                     Type                    Description
	  ------------------------- ----------------------- -------------------------
	  keyboard                  Array of Array of       Array of button rows,
	                            KeyboardButton          each represented by an
	                                                    Array of KeyboardButton
	                                                    objects
	
	  is_persistent             Boolean                 *Optional*. Requests
	                                                    clients to always show
	                                                    the keyboard when the
	                                                    regular keyboard is
	                                                    hidden. Defaults to
	                                                    *false*, in which case
	                                                    the custom keyboard can
	                                                    be hidden and opened with
	                                                    a keyboard icon.
	
	  resize_keyboard           Boolean                 *Optional*. Requests
	                                                    clients to resize the
	                                                    keyboard vertically for
	                                                    optimal fit (e.g., make
	                                                    the keyboard smaller if
	                                                    there are just two rows
	                                                    of buttons). Defaults to
	                                                    *false*, in which case
	                                                    the custom keyboard is
	                                                    always of the same height
	                                                    as the app's standard
	                                                    keyboard.
	
	  one_time_keyboard         Boolean                 *Optional*. Requests
	                                                    clients to hide the
	                                                    keyboard as soon as it's
	                                                    been used. The keyboard
	                                                    will still be available,
	                                                    but clients will
	                                                    automatically display the
	                                                    usual letter-keyboard in
	                                                    the chat - the user can
	                                                    press a special button in
	                                                    the input field to see
	                                                    the custom keyboard
	                                                    again. Defaults to
	                                                    *false*.
	
	  input_field_placeholder   String                  *Optional*. The
	                                                    placeholder to be shown
	                                                    in the input field when
	                                                    the keyboard is active;
	                                                    1-64 characters
	
	  selective                 Boolean                 *Optional*. Use this
	                                                    parameter if you want to
	                                                    show the keyboard to
	                                                    specific users only.
	                                                    Targets: 1) users that
	                                                    are @mentioned in the
	                                                    *text* of the Message
	                                                    object; 2) if the bot's
	                                                    message is a reply (has
	                                                    *reply_to_message_id*),
	                                                    sender of the original
	                                                    message.
	                                                    
	                                                    *Example:* A user
	                                                    requests to change the
	                                                    bot's language, bot
	                                                    replies to the request
	                                                    with a keyboard to select
	                                                    the new language. Other
	                                                    users in the group don't
	                                                    see the keyboard.
	  ---------------------------------------------------------------------------
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ReplyKeyboardMarkup" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
