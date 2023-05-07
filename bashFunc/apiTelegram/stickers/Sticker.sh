## sticker # This object represents a sticker.
# https://core.telegram.org/bots/api#sticker

function Sticker ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a sticker.
	Ref: https://core.telegram.org/bots/api#sticker
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object represents a sticker.
	
	  Field               Type           Description
	  ------------------- -------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  file_id             String         Identifier for this file, which can be used to download or reuse the file
	  file_unique_id      String         Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
	  type                String         Type of the sticker, currently one of "regular", "mask", "custom_emoji". The type of the sticker is independent from its format, which is determined by the fields *is_animated* and *is_video*.
	  width               Integer        Sticker width
	  height              Integer        Sticker height
	  is_animated         Boolean        *True*, if the sticker is animated
	  is_video            Boolean        *True*, if the sticker is a video sticker
	  thumbnail           PhotoSize      *Optional*. Sticker thumbnail in the .WEBP or .JPG format
	  emoji               String         *Optional*. Emoji associated with the sticker
	  set_name            String         *Optional*. Name of the sticker set to which the sticker belongs
	  premium_animation   File           *Optional*. For premium regular stickers, premium animation for the sticker
	  mask_position       MaskPosition   *Optional*. For mask stickers, the position where the mask should be placed
	  custom_emoji_id     String         *Optional*. For custom emoji stickers, unique identifier of the custom emoji
	  needs_repainting    True           *Optional*. *True*, if the sticker must be repainted to a text color in messages, the color of the Telegram Premium badge in emoji status, white color on chat photos, or another appropriate color in other places
	  file_size           Integer        *Optional*. File size in bytes
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/Sticker" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
