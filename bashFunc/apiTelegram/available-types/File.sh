## file # This object represents a file ready to be downloaded.
# https://core.telegram.org/bots/api#file

function File ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a file ready to be downloaded.
	Ref: https://core.telegram.org/bots/api#file
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
This object represents a file ready to be downloaded. The file can be
downloaded via the link
`https://api.telegram.org/file/bot<token>/<file_path>`. It is guaranteed
that the link will be valid for at least 1 hour. When the link expires,
a new one can be requested by calling getFile.
> The maximum file size to download is 20 MB
  Field            Type      Description
  ---------------- --------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  file_id          String    Identifier for this file, which can be used to download or reuse the file
  file_unique_id   String    Unique identifier for this file, which is supposed to be the same over time and for different bots. Can\'t be used to download or reuse the file.
  file_size        Integer   *Optional*. File size in bytes. It can be bigger than 2\^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
  file_path        String    *Optional*. File path. Use `https://api.telegram.org/file/bot<token>/<file_path>` to get the file.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/File\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
