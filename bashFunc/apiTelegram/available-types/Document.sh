## document # This object represents a general file (as opposed to photos, voice messages and audio files).
# https://core.telegram.org/bots/api#document

function Document ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a general file (as opposed to photos, voice messages and audio files).
	Ref: https://core.telegram.org/bots/api#document
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a general file (as opposed to photos, voice
messages and audio files).
  Field            Type        Description
  ---------------- ----------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  file_id          String      Identifier for this file, which can be used to download or reuse the file
  file_unique_id   String      Unique identifier for this file, which is supposed to be the same over time and for different bots. Can\'t be used to download or reuse the file.
  thumbnail        PhotoSize   *Optional*. Document thumbnail as defined by sender
  file_name        String      *Optional*. Original filename as defined by sender
  mime_type        String      *Optional*. MIME type of the file as defined by sender
  file_size        Integer     *Optional*. File size in bytes. It can be bigger than 2\^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/Document\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
