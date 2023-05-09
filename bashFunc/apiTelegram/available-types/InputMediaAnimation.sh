## inputmediaanimation # Represents an animation file (GIF or H.
# https://core.telegram.org/bots/api#inputmediaanimation

function InputMediaAnimation ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents an animation file (GIF or H.
	Ref: https://core.telegram.org/bots/api#inputmediaanimation
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Represents an animation file (GIF or H.264/MPEG-4 AVC video without
sound) to be sent.
  Field              Type                     Description
  ------------------ ------------------------ --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  type               String                   Type of the result, must be *animation*
  media              String                   File to send. Pass a file_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass "attach://\<file_attach_name\>" to upload a new one using multipart/form-data under \<file_attach_name\> name. More information on Sending Files »
  thumbnail          InputFile or String      *Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail\'s width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can\'t be reused and can be only uploaded as a new file, so you can pass "attach://\<file_attach_name\>" if the thumbnail was uploaded using multipart/form-data under \<file_attach_name\>. More information on Sending Files »
  caption            String                   *Optional*. Caption of the animation to be sent, 0-1024 characters after entities parsing
  parse_mode         String                   *Optional*. Mode for parsing entities in the animation caption. See formatting options for more details.
  caption_entities   Array of MessageEntity   *Optional*. List of special entities that appear in the caption, which can be specified instead of *parse_mode*
  width              Integer                  *Optional*. Animation width
  height             Integer                  *Optional*. Animation height
  duration           Integer                  *Optional*. Animation duration in seconds
  has_spoiler        Boolean                  *Optional*. Pass *True* if the animation needs to be covered with a spoiler animation
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputMediaAnimation\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
