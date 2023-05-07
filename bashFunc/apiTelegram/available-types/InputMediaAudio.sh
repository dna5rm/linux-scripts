## inputmediaaudio # Represents an audio file to be treated as music to be sent.
# https://core.telegram.org/bots/api#inputmediaaudio

function InputMediaAudio ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an audio file to be treated as music to be sent.
	Ref: https://core.telegram.org/bots/api#inputmediaaudio
	---
	Represents an audio file to be treated as music to be sent.
	
	  Field              Type                     Description
	  ------------------ ------------------------ --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  type               String                   Type of the result, must be *audio*
	  media              String                   File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://<file_attach_name>" to upload a new one using multipart/form-data under <file_attach_name> name. More information on Sending Files »
	  thumbnail          InputFile or String      *Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass "attach://<file_attach_name>" if the thumbnail was uploaded using multipart/form-data under <file_attach_name>. More information on Sending Files »
	  caption            String                   *Optional*. Caption of the audio to be sent, 0-1024 characters after entities parsing
	  parse_mode         String                   *Optional*. Mode for parsing entities in the audio caption. See formatting options for more details.
	  caption_entities   Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
	  duration           Integer                  *Optional*. Duration of the audio in seconds
	  performer          String                   *Optional*. Performer of the audio
	  title              String                   *Optional*. Title of the audio
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputMediaAudio" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
