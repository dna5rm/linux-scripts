## userprofilephotos # This object represent a user's profile pictures.
# https://core.telegram.org/bots/api#userprofilephotos

function UserProfilePhotos ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - This object represent a user's profile pictures.
	Ref: https://core.telegram.org/bots/api#userprofilephotos
	---
	This object represent a user's profile pictures.
	
	  Field         Type                          Description
	  ------------- ----------------------------- ------------------------------------------------------
	  total_count   Integer                       Total number of profile pictures the target user has
	  photos        Array of Array of PhotoSize   Requested profile pictures (in up to 4 sizes each)
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/UserProfilePhotos" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
