## getuserprofilephotos # Use this method to get a list of profile pictures for a user.
# https://core.telegram.org/bots/api#getuserprofilephotos

function getUserProfilePhotos ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to get a list of profile pictures for a user.
	Ref: https://core.telegram.org/bots/api#getuserprofilephotos
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to get a list of profile pictures for a user. Returns a
UserProfilePhotos object.
  Parameter   Type      Required   Description
  ----------- --------- ---------- --------------------------------------------------------------------------------------------------
  user_id     Integer   Yes        Unique identifier of the target user
  offset      Integer   Optional   Sequential number of the first photo to be returned. By default, all photos are returned.
  limit       Integer   Optional   Limits the number of photos to be retrieved. Values between 1-100 are accepted. Defaults to 100.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getUserProfilePhotos" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          $(jq -jr 'keys[] as $k | "--form \($k)=\(.[$k]) "' <<<"${1:-{\}}")
    fi
}
