## replykeyboardremove # Upon receiving a message with this object, Telegram clients will remove the current custom keyboard and display the default letter-keyboard.
# https://core.telegram.org/bots/api#replykeyboardremove

function ReplyKeyboardRemove ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Upon receiving a message with this object, Telegram clients will remove the current custom keyboard and display the default letter-keyboard.
	Ref: https://core.telegram.org/bots/api#replykeyboardremove
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Upon receiving a message with this object, Telegram clients will remove
the current custom keyboard and display the default letter-keyboard. By
default, custom keyboards are displayed until a new keyboard is sent by
a bot. An exception is made for one-time keyboards that are hidden
immediately after the user presses a button (see ReplyKeyboardMarkup).
  -------------------------------------------------------------------------
  Field                   Type                    Description
  ----------------------- ----------------------- -------------------------
  remove_keyboard         True                    Requests clients to
                                                  remove the custom
                                                  keyboard (user will not
                                                  be able to summon this
                                                  keyboard; if you want to
                                                  hide the keyboard from
                                                  sight but keep it
                                                  accessible, use
                                                  *one_time_keyboard* in
                                                  ReplyKeyboardMarkup)
  selective               Boolean                 *Optional*. Use this
                                                  parameter if you want to
                                                  remove the keyboard for
                                                  specific users only.
                                                  Targets: 1) users that
                                                  are \@mentioned in the
                                                  *text* of the Message
                                                  object; 2) if the bot\'s
                                                  message is a reply (has
                                                  *reply_to_message_id*),
                                                  sender of the original
                                                  message.\
                                                  \
                                                  *Example:* A user votes
                                                  in a poll, bot returns
                                                  confirmation message in
                                                  reply to the vote and
                                                  removes the keyboard for
                                                  that user, while still
                                                  showing the keyboard with
                                                  poll options to users who
                                                  haven\'t voted yet.
  -------------------------------------------------------------------------
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/ReplyKeyboardRemove\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
