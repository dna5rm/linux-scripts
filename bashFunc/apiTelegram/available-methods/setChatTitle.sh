## setchattitle # Use this method to change the title of a chat.
# https://core.telegram.org/bots/api#setchattitle

function setChatTitle ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the title of a chat.
	Ref: https://core.telegram.org/bots/api#setchattitle
	---
	Use this method to change the title of a chat. Titles can't be changed
	for private chats. The bot must be an administrator in the chat for this
	to work and must have the appropriate administrator rights. Returns
	*True* on success.
	
	  Parameter   Type                Required   Description
	  ----------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------
	  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
	  title       String              Yes        New chat title, 1-128 characters
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setChatTitle" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
