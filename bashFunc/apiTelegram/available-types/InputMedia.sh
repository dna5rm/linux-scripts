## inputmedia # This object represents the content of a media message to be sent.
# https://core.telegram.org/bots/api#inputmedia

function InputMedia ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represents the content of a media message to be sent.
	Ref: https://core.telegram.org/bots/api#inputmedia
	---
	This object represents the content of a media message to be sent. It
	should be one of
	
	-   InputMediaAnimation
	-   InputMediaDocument
	-   InputMediaAudio
	-   InputMediaPhoto
	-   InputMediaVideo
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/InputMedia" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
