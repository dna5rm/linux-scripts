## setwebhook # Use this method to specify a URL and receive incoming updates via an outgoing webhook.
# https://core.telegram.org/bots/api#setwebhook

function setWebhook ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to specify a URL and receive incoming updates via an outgoing webhook.
	Ref: https://core.telegram.org/bots/api#setwebhook
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
Use this method to specify a URL and receive incoming updates via an
outgoing webhook. Whenever there is an update for the bot, we will send
an HTTPS POST request to the specified URL, containing a JSON-serialized
Update. In case of an unsuccessful request, we will give up after a
reasonable amount of attempts. Returns *True* on success.
If you\'d like to make sure that the webhook was set by you, you can
specify secret data in the parameter *secret_token*. If specified, the
request will contain a header "X-Telegram-Bot-Api-Secret-Token" with the
secret token as content.
  ----------------------------------------------------------------------------------------------
  Parameter              Type              Required          Description
  ---------------------- ----------------- ----------------- -----------------------------------
  url                    String            Yes               HTTPS URL to send updates to. Use
                                                             an empty string to remove webhook
                                                             integration
  certificate            InputFile         Optional          Upload your public key certificate
                                                             so that the root certificate in use
                                                             can be checked. See our self-signed
                                                             guide for details.
  ip_address             String            Optional          The fixed IP address which will be
                                                             used to send webhook requests
                                                             instead of the IP address resolved
                                                             through DNS
  max_connections        Integer           Optional          The maximum allowed number of
                                                             simultaneous HTTPS connections to
                                                             the webhook for update delivery,
                                                             1-100. Defaults to *40*. Use lower
                                                             values to limit the load on your
                                                             bot\'s server, and higher values to
                                                             increase your bot\'s throughput.
  allowed_updates        Array of String   Optional          A JSON-serialized list of the
                                                             update types you want your bot to
                                                             receive. For example, specify
                                                             \["message", "edited_channel_post",
                                                             "callback_query"\] to only receive
                                                             updates of these types. See Update
                                                             for a complete list of available
                                                             update types. Specify an empty list
                                                             to receive all update types except
                                                             *chat_member* (default). If not
                                                             specified, the previous setting
                                                             will be used.\
                                                             Please note that this parameter
                                                             doesn\'t affect updates created
                                                             before the call to the setWebhook,
                                                             so unwanted updates may be received
                                                             for a short period of time.
  drop_pending_updates   Boolean           Optional          Pass *True* to drop all pending
                                                             updates
  secret_token           String            Optional          A secret token to be sent in a
                                                             header
                                                             "X-Telegram-Bot-Api-Secret-Token"
                                                             in every webhook request, 1-256
                                                             characters. Only characters `A-Z`,
                                                             `a-z`, `0-9`, `_` and `-` are
                                                             allowed. The header is useful to
                                                             ensure that the request comes from
                                                             a webhook set by you.
  ----------------------------------------------------------------------------------------------
> **Notes**\
> **1.** You will not be able to receive updates using getUpdates for as
> long as an outgoing webhook is set up.\
> **2.** To use a self-signed certificate, you need to upload your
> public key certificate using *certificate* parameter. Please upload as
> InputFile, sending a String will not work.\
> **3.** Ports currently supported *for webhooks*: **443, 80, 88,
> 8443**.
>
> If you\'re having any trouble setting up webhooks, please check out
> this amazing guide to webhooks.
	EOF
    else
                # Construct a curl CMD string to eval
                cmd=( "curl --silent --location --request POST" )
                cmd+=( "--url \"https://api.telegram.org/bot${TELEGRAM_TOKEN}/setWebhook\"" )
                cmd+=( "--header \"Content-Type: multipart/form-data\"" )
                cmd+=( "--header \"Accept: application/json\"" )

                # Prevent command injection by filtering through sed.
                cmd+=( `jq -r 'to_entries[] | "--form \""+"\(.key)=\(.value|@text)\""' <<<"${@:-{\}}" | sed 's/[$]/\\&/g'` )

                # Run the CMD
                eval ${cmd[@]}
    fi
}
