## photosize # This object represents one size of a photo or a file / sticker thumbnail.
# https://core.telegram.org/bots/api#photosize

function PhotoSize ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents one size of a photo or a file / sticker thumbnail.
	Ref: https://core.telegram.org/bots/api#photosize
	---
	This object represents one size of a photo or a file / sticker
	thumbnail.
	
	  Field            Type      Description
	  ---------------- --------- ---------------------------------------------------------------------------------------------------------------------------------------------------
	  file_id          String    Identifier for this file, which can be used to download or reuse the file
	  file_unique_id   String    Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.
	  width            Integer   Photo width
	  height           Integer   Photo height
	  file_size        Integer   *Optional*. File size in bytes
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/PhotoSize" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
