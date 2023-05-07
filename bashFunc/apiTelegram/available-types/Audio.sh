## audio # This object represents an audio file to be treated as music by the Telegram clients.
# https://core.telegram.org/bots/api#audio

function Audio ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents an audio file to be treated as music by the Telegram clients.
	Ref: https://core.telegram.org/bots/api#audio
	---
	This object represents an audio file to be treated as music by the
	Telegram clients.
	
	  Field            Type        Description
	  ---------------- ----------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  file_id          String      Identifier for this file, which can be used to download or reuse the file
	  file_unique_id   String      Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
	  duration         Integer     Duration of the audio in seconds as defined by sender
	  performer        String      *Optional*. Performer of the audio as defined by sender or by audio tags
	  title            String      *Optional*. Title of the audio as defined by sender or by audio tags
	  file_name        String      *Optional*. Original filename as defined by sender
	  mime_type        String      *Optional*. MIME type of the file as defined by sender
	  file_size        Integer     *Optional*. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.
	  thumbnail        PhotoSize   *Optional*. Thumbnail of the album cover to which the music file belongs
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/Audio" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
