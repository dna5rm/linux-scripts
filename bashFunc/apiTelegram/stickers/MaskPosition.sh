## maskposition # This object describes the position on faces where a mask should be placed by default.
# https://core.telegram.org/bots/api#maskposition

function MaskPosition ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object describes the position on faces where a mask should be placed by default.
	Ref: https://core.telegram.org/bots/api#maskposition
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object describes the position on faces where a mask should be
placed by default.
  Field     Type           Description
  --------- -------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  point     String         The part of the face relative to which the mask should be placed. One of "forehead", "eyes", "mouth", or "chin".
  x_shift   Float number   Shift by X-axis measured in widths of the mask scaled to the face size, from left to right. For example, choosing -1.0 will place mask just to the left of the default mask position.
  y_shift   Float number   Shift by Y-axis measured in heights of the mask scaled to the face size, from top to bottom. For example, 1.0 will place the mask just below the default mask position.
  scale     Float number   Mask scaling coefficient. For example, 2.0 means double size.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/MaskPosition" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
