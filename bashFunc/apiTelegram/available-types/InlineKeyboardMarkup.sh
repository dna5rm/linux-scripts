## inlinekeyboardmarkup # This object represents an inline keyboard that appears right next to the message it belongs to.
# https://core.telegram.org/bots/api#inlinekeyboardmarkup

function InlineKeyboardMarkup ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an inline keyboard that appears right next to the message it belongs to.
	Ref: https://core.telegram.org/bots/api#inlinekeyboardmarkup
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents an inline keyboard that appears right next to the
message it belongs to.
  Field             Type                                     Description
  ----------------- ---------------------------------------- ------------------------------------------------------------------------------------
  inline_keyboard   Array of Array of InlineKeyboardButton   Array of button rows, each represented by an Array of InlineKeyboardButton objects
**Note:** This will only work in Telegram versions released after 9
April, 2016. Older clients will display *unsupported message*.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineKeyboardMarkup\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
