## inlinequeryresult # This object represents one result of an inline query.
# https://core.telegram.org/bots/api#inlinequeryresult

function InlineQueryResult ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents one result of an inline query.
	Ref: https://core.telegram.org/bots/api#inlinequeryresult
	---
	This object represents one result of an inline query. Telegram clients
	currently support results of the following 20 types:
	
	-   InlineQueryResultCachedAudio
	-   InlineQueryResultCachedDocument
	-   InlineQueryResultCachedGif
	-   InlineQueryResultCachedMpeg4Gif
	-   InlineQueryResultCachedPhoto
	-   InlineQueryResultCachedSticker
	-   InlineQueryResultCachedVideo
	-   InlineQueryResultCachedVoice
	-   InlineQueryResultArticle
	-   InlineQueryResultAudio
	-   InlineQueryResultContact
	-   InlineQueryResultGame
	-   InlineQueryResultDocument
	-   InlineQueryResultGif
	-   InlineQueryResultLocation
	-   InlineQueryResultMpeg4Gif
	-   InlineQueryResultPhoto
	-   InlineQueryResultVenue
	-   InlineQueryResultVideo
	-   InlineQueryResultVoice
	
	**Note:** All URLs passed in inline query results will be available to
	end users and therefore must be assumed to be **public**.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResult" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
