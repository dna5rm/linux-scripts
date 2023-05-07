## getforumtopiciconstickers # Use this method to get custom emoji stickers, which can be used as a forum topic icon by any user.
# https://core.telegram.org/bots/api#getforumtopiciconstickers

function getForumTopicIconStickers ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get custom emoji stickers, which can be used as a forum topic icon by any user.
	Ref: https://core.telegram.org/bots/api#getforumtopiciconstickers
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to get custom emoji stickers, which can be used as a
	forum topic icon by any user. Requires no parameters. Returns an Array
	of Sticker objects.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getForumTopicIconStickers" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
