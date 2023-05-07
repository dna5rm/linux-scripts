## getupdates # Use this method to receive incoming updates using long polling (wiki).
# https://core.telegram.org/bots/api#getupdates

function getUpdates ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to receive incoming updates using long polling (wiki).
	Ref: https://core.telegram.org/bots/api#getupdates
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to receive incoming updates using long polling (wiki).
	Returns an Array of Update objects.
	
	  ------------------------------------------------------------------------------
	  Parameter         Type              Required          Description
	  ----------------- ----------------- ----------------- ------------------------
	  offset            Integer           Optional          Identifier of the first
	                                                        update to be returned.
	                                                        Must be greater by one
	                                                        than the highest among
	                                                        the identifiers of
	                                                        previously received
	                                                        updates. By default,
	                                                        updates starting with
	                                                        the earliest unconfirmed
	                                                        update are returned. An
	                                                        update is considered
	                                                        confirmed as soon as
	                                                        getUpdates is called
	                                                        with an *offset* higher
	                                                        than its *update_id*.
	                                                        The negative offset can
	                                                        be specified to retrieve
	                                                        updates starting from
	                                                        *-offset* update from
	                                                        the end of the updates
	                                                        queue. All previous
	                                                        updates will be
	                                                        forgotten.
	
	  limit             Integer           Optional          Limits the number of
	                                                        updates to be retrieved.
	                                                        Values between 1-100 are
	                                                        accepted. Defaults to
	                                                        100.
	
	  timeout           Integer           Optional          Timeout in seconds for
	                                                        long polling. Defaults
	                                                        to 0, i.e. usual short
	                                                        polling. Should be
	                                                        positive, short polling
	                                                        should be used for
	                                                        testing purposes only.
	
	  allowed_updates   Array of String   Optional          A JSON-serialized list
	                                                        of the update types you
	                                                        want your bot to
	                                                        receive. For example,
	                                                        specify ["message",
	                                                        "edited_channel_post",
	                                                        "callback_query"] to
	                                                        only receive updates of
	                                                        these types. See Update
	                                                        for a complete list of
	                                                        available update types.
	                                                        Specify an empty list to
	                                                        receive all update types
	                                                        except *chat_member*
	                                                        (default). If not
	                                                        specified, the previous
	                                                        setting will be used.
	                                                        
	                                                        Please note that this
	                                                        parameter doesn't
	                                                        affect updates created
	                                                        before the call to the
	                                                        getUpdates, so unwanted
	                                                        updates may be received
	                                                        for a short period of
	                                                        time.
	  ------------------------------------------------------------------------------
	
	> **Notes**
	> **1.** This method will not work if an outgoing webhook is set up.
	> **2.** In order to avoid getting duplicate updates, recalculate
	> *offset* after each server response.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getUpdates" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
