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

    if [[ -z "${TELEGRAM_TOKEN}" ]] || [[ -z "$(grep -E "+{*}+" <<<${1:-{\}} 2> /dev/null)" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents one result of an inline query.
	Ref: https://core.telegram.org/bots/api#inlinequeryresult
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
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
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InlineQueryResult\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
