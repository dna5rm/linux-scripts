## chatphoto # This object represents a chat photo.
# https://core.telegram.org/bots/api#chatphoto

function ChatPhoto ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a chat photo.
	Ref: https://core.telegram.org/bots/api#chatphoto
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a chat photo.
  Field                  Type     Description
  ---------------------- -------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  small_file_id          String   File identifier of small (160x160) chat photo. This file_id can be used only for photo download and only for as long as the photo is not changed.
  small_file_unique_id   String   Unique file identifier of small (160x160) chat photo, which is supposed to be the same over time and for different bots. Can\'t be used to download or reuse the file.
  big_file_id            String   File identifier of big (640x640) chat photo. This file_id can be used only for photo download and only for as long as the photo is not changed.
  big_file_unique_id     String   Unique file identifier of big (640x640) chat photo, which is supposed to be the same over time and for different bots. Can\'t be used to download or reuse the file.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatPhoto\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
