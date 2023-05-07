## chatjoinrequest # Represents a join request sent to a chat.
# https://core.telegram.org/bots/api#chatjoinrequest

function ChatJoinRequest ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Represents a join request sent to a chat.
	Ref: https://core.telegram.org/bots/api#chatjoinrequest
	---
	Represents a join request sent to a chat.
	
	  Field          Type             Description
	  -------------- ---------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat           Chat             Chat to which the request was sent
	  from           User             User that sent the join request
	  user_chat_id   Integer          Identifier of a private chat with the user who sent the join request. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot can use this identifier for 24 hours to send messages until the join request is processed, assuming no other administrator contacted the user.
	  date           Integer          Date the request was sent in Unix time
	  bio            String           *Optional*. Bio of the user.
	  invite_link    ChatInviteLink   *Optional*. Chat invite link that was used by the user to send the join request
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/ChatJoinRequest" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1}"
    fi
}
