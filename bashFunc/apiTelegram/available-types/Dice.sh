## dice # This object represents an animated emoji that displays a random value.
# https://core.telegram.org/bots/api#dice

function Dice ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an animated emoji that displays a random value.
	Ref: https://core.telegram.org/bots/api#dice
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents an animated emoji that displays a random value.
  Field   Type      Description
  ------- --------- -----------------------------------------------------------------------------------------------------------
  emoji   String    Emoji on which the dice throw animation is based
  value   Integer   Value of the dice, 1-6 for "", "" and "" base emoji, 1-5 for "" and "" base emoji, 1-64 for "" base emoji
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/Dice" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
