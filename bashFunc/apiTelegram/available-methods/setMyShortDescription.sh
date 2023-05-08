## setmyshortdescription # Use this method to change the bot's short description, which is shown on the bot's profile page and is sent together with the link when users share the bot.
# https://core.telegram.org/bots/api#setmyshortdescription

function setMyShortDescription ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to change the bot's short description, which is shown on the bot's profile page and is sent together with the link when users share the bot.
	Ref: https://core.telegram.org/bots/api#setmyshortdescription
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to change the bot\'s short description, which is shown
on the bot\'s profile page and is sent together with the link when users
share the bot. Returns *True* on success.
  Parameter           Type     Required   Description
  ------------------- -------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  short_description   String   Optional   New short description for the bot; 0-120 characters. Pass an empty string to remove the dedicated short description for the given language.
  language_code       String   Optional   A two-letter ISO 639-1 language code. If empty, the short description will be applied to all users for whose language there is no dedicated short description.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setMyShortDescription" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
