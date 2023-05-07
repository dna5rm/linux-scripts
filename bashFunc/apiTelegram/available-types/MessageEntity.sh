## messageentity # This object represents one special entity in a text message.
# https://core.telegram.org/bots/api#messageentity

function MessageEntity ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents one special entity in a text message.
	Ref: https://core.telegram.org/bots/api#messageentity
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	This object represents one special entity in a text message. For
	example, hashtags, usernames, URLs, etc.
	
	  Field             Type      Description
	  ----------------- --------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  type              String    Type of the entity. Currently, can be "mention" (\`@username\`), "hashtag" (\`#hashtag\`), "cashtag" (\`$USD\`), "bot_command" (\`/start@jobs_bot\`), "url" (\`https://telegram.org\`), "email" (\`do-not-reply@telegram.org\`), "phone_number" (\`+1-212-555-0123\`), "bold" (**bold text**), "italic" (*italic text*), "underline" (underlined text), "strikethrough" (strikethrough text), "spoiler" (spoiler message), "code" (monowidth string), "pre" (monowidth block), "text_link" (for clickable text URLs), "text_mention" (for users without usernames), "custom_emoji" (for inline custom emoji stickers)
	  offset            Integer   Offset in UTF-16 code units to the start of the entity
	  length            Integer   Length of the entity in UTF-16 code units
	  url               String    *Optional*. For "text_link" only, URL that will be opened after user taps on the text
	  user              User      *Optional*. For "text_mention" only, the mentioned user
	  language          String    *Optional*. For "pre" only, the programming language of the entity text
	  custom_emoji_id   String    *Optional*. For "custom_emoji" only, unique identifier of the custom emoji. Use getCustomEmojiStickers to get full information about the sticker
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/MessageEntity" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
