## setchatphoto # Use this method to set a new profile photo for the chat.
# https://core.telegram.org/bots/api#setchatphoto

function setChatPhoto ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to set a new profile photo for the chat.
	Ref: https://core.telegram.org/bots/api#setchatphoto
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to set a new profile photo for the chat. Photos can\'t
be changed for private chats. The bot must be an administrator in the
chat for this to work and must have the appropriate administrator
rights. Returns *True* on success.
  Parameter   Type                Required   Description
  ----------- ------------------- ---------- ------------------------------------------------------------------------------------------------------------
  chat_id     Integer or String   Yes        Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)
  photo       InputFile           Yes        New chat photo, uploaded using multipart/form-data
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setChatPhoto" \
          --header "Content-Type: multipart/form-data" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
