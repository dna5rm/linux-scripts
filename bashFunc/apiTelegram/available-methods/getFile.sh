## getfile # Use this method to get basic information about a file and prepare it for downloading.
# https://core.telegram.org/bots/api#getfile

function getFile ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get basic information about a file and prepare it for downloading.
	Ref: https://core.telegram.org/bots/api#getfile
	---
	Use this method to get basic information about a file and prepare it for
	downloading. For the moment, bots can download files of up to 20MB in
	size. On success, a File object is returned. The file can then be
	downloaded via the link
	`https://api.telegram.org/file/bot<token>/<file_path>`, where
	`<file_path>` is taken from the response. It is guaranteed that the link
	will be valid for at least 1 hour. When the link expires, a new one can
	be requested by calling getFile again.
	
	  Parameter   Type     Required   Description
	  ----------- -------- ---------- ------------------------------------------
	  file_id     String   Yes        File identifier to get information about
	
	**Note:** This function may not preserve the original file name and MIME
	type. You should save the file's MIME type and name (if available) when
	the File object is received.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getFile" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
