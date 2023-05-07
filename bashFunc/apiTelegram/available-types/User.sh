## user # This object represents a Telegram user or bot.
# https://core.telegram.org/bots/api#user

function User ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a Telegram user or bot.
	Ref: https://core.telegram.org/bots/api#user
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object represents a Telegram user or bot.
	
	  Field                         Type      Description
	  ----------------------------- --------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  id                            Integer   Unique identifier for this user or bot. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.
	  is_bot                        Boolean   *True*, if this user is a bot
	  first_name                    String    User's or bot's first name
	  last_name                     String    *Optional*. User's or bot's last name
	  username                      String    *Optional*. User's or bot's username
	  language_code                 String    *Optional*. IETF language tag of the user's language
	  is_premium                    True      *Optional*. *True*, if this user is a Telegram Premium user
	  added_to_attachment_menu      True      *Optional*. *True*, if this user added the bot to the attachment menu
	  can_join_groups               Boolean   *Optional*. *True*, if the bot can be invited to groups. Returned only in getMe.
	  can_read_all_group_messages   Boolean   *Optional*. *True*, if privacy mode is disabled for the bot. Returned only in getMe.
	  supports_inline_queries       Boolean   *Optional*. *True*, if the bot supports inline queries. Returned only in getMe.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/User" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
