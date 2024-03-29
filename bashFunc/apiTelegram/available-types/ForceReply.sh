## forcereply # Upon receiving a message with this object, Telegram clients will display a reply interface to the user (act as if the user has selected the bot's message and tapped 'Reply').
# https://core.telegram.org/bots/api#forcereply

function ForceReply ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Upon receiving a message with this object, Telegram clients will display a reply interface to the user (act as if the user has selected the bot's message and tapped 'Reply').
	Ref: https://core.telegram.org/bots/api#forcereply
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Upon receiving a message with this object, Telegram clients will display
a reply interface to the user (act as if the user has selected the
bot\'s message and tapped \'Reply\'). This can be extremely useful if
you want to create user-friendly step-by-step interfaces without having
to sacrifice privacy mode.
  Field                     Type      Description
  ------------------------- --------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  force_reply               True      Shows reply interface to the user, as if they manually selected the bot\'s message and tapped \'Reply\'
  input_field_placeholder   String    *Optional*. The placeholder to be shown in the input field when the reply is active; 1-64 characters
  selective                 Boolean   *Optional*. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are \@mentioned in the *text* of the Message object; 2) if the bot\'s message is a reply (has *reply_to_message_id*), sender of the original message.
> **Example:** A poll bot for groups runs in privacy mode (only receives
> commands, replies to its messages and mentions). There could be two
> ways to create a new poll:
>
> -   Explain the user how to send a command with parameters (e.g.
>     /newpoll question answer1 answer2). May be appealing for hardcore
>     users but lacks modern day polish.
> -   Guide the user through a step-by-step process. \'Please send me
>     your question\', \'Cool, now let\'s add the first answer option\',
>     \'Great. Keep adding answer options, then send /done when you\'re
>     ready\'.
>
> The last option is definitely more attractive. And if you use
> ForceReply in your bot\'s questions, it will receive the user\'s
> answers even if it only receives replies, commands and mentions -
> without any extra work for the user.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/ForceReply\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
