## setchatadministratorcustomtitle # Use this method to set a custom title for an administrator in a supergroup promoted by the bot.
# https://core.telegram.org/bots/api#setchatadministratorcustomtitle

function setChatAdministratorCustomTitle ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to set a custom title for an administrator in a supergroup promoted by the bot.
	Ref: https://core.telegram.org/bots/api#setchatadministratorcustomtitle
	---
	Use this method to set a custom title for an administrator in a
	supergroup promoted by the bot. Returns *True* on success.
	
	  Parameter      Type                Required   Description
	  -------------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------------
	  chat_id        Integer or String   Yes        Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)
	  user_id        Integer             Yes        Unique identifier of the target user
	  custom_title   String              Yes        New custom title for the administrator; 0-16 characters, emoji are not allowed
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setChatAdministratorCustomTitle" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
