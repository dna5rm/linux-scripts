## videonote # This object represents a video message (available in Telegram apps as of v.
# https://core.telegram.org/bots/api#videonote

function VideoNote ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents a video message (available in Telegram apps as of v.
	Ref: https://core.telegram.org/bots/api#videonote
	---
	This object represents a video message (available in Telegram apps as of
	v.4.0).
	
	  Field            Type        Description
	  ---------------- ----------- ---------------------------------------------------------------------------------------------------------------------------------------------------
	  file_id          String      Identifier for this file, which can be used to download or reuse the file
	  file_unique_id   String      Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
	  length           Integer     Video width and height (diameter of the video message) as defined by sender
	  duration         Integer     Duration of the video in seconds as defined by sender
	  thumbnail        PhotoSize   *Optional*. Video thumbnail
	  file_size        Integer     *Optional*. File size in bytes
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/VideoNote" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
