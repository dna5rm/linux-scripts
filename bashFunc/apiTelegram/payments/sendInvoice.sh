## sendinvoice # Use this method to send invoices.
# https://core.telegram.org/bots/api#sendinvoice

function sendInvoice ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Use this method to send invoices.
	Ref: https://core.telegram.org/bots/api#sendinvoice
	---
	Telegram API Token: \${TELEGRAM_TOKEN} (${TELEGRAM_TOKEN:-required})
	---
	Use this method to send invoices. On success, the sent Message is
	returned.
	
	  Parameter                       Type                    Required   Description
	  ------------------------------- ----------------------- ---------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  chat_id                         Integer or String       Yes        Unique identifier for the target chat or username of the target channel (in the format \`@channelusername\`)
	  message_thread_id               Integer                 Optional   Unique identifier for the target message thread (topic) of the forum; for forum supergroups only
	  title                           String                  Yes        Product name, 1-32 characters
	  description                     String                  Yes        Product description, 1-255 characters
	  payload                         String                  Yes        Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use for your internal processes.
	  provider_token                  String                  Yes        Payment provider token, obtained via @BotFather
	  currency                        String                  Yes        Three-letter ISO 4217 currency code, see more on currencies
	  prices                          Array of LabeledPrice   Yes        Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.)
	  max_tip_amount                  Integer                 Optional   The maximum accepted amount for tips in the *smallest units* of the currency (integer, **not** float/double). For example, for a maximum tip of \`US$ 1.45\` pass \`max_tip_amount = 145\`. See the *exp* parameter in currencies.json, it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0
	  suggested_tip_amounts           Array of Integer        Optional   A JSON-serialized array of suggested amounts of tips in the *smallest units* of the currency (integer, **not** float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed *max_tip_amount*.
	  start_parameter                 String                  Optional   Unique deep-linking parameter. If left empty, **forwarded copies** of the sent message will have a *Pay* button, allowing multiple users to pay directly from the forwarded message, using the same invoice. If non-empty, forwarded copies of the sent message will have a *URL* button with a deep link to the bot (instead of a *Pay* button), with the value used as the start parameter
	  provider_data                   String                  Optional   JSON-serialized data about the invoice, which will be shared with the payment provider. A detailed description of required fields should be provided by the payment provider.
	  photo_url                       String                  Optional   URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service. People like it better when they see what they are paying for.
	  photo_size                      Integer                 Optional   Photo size in bytes
	  photo_width                     Integer                 Optional   Photo width
	  photo_height                    Integer                 Optional   Photo height
	  need_name                       Boolean                 Optional   Pass *True* if you require the user's full name to complete the order
	  need_phone_number               Boolean                 Optional   Pass *True* if you require the user's phone number to complete the order
	  need_email                      Boolean                 Optional   Pass *True* if you require the user's email address to complete the order
	  need_shipping_address           Boolean                 Optional   Pass *True* if you require the user's shipping address to complete the order
	  send_phone_number_to_provider   Boolean                 Optional   Pass *True* if the user's phone number should be sent to provider
	  send_email_to_provider          Boolean                 Optional   Pass *True* if the user's email address should be sent to provider
	  is_flexible                     Boolean                 Optional   Pass *True* if the final price depends on the shipping method
	  disable_notification            Boolean                 Optional   Sends the message silently. Users will receive a notification with no sound.
	  protect_content                 Boolean                 Optional   Protects the contents of the sent message from forwarding and saving
	  reply_to_message_id             Integer                 Optional   If the message is a reply, ID of the original message
	  allow_sending_without_reply     Boolean                 Optional   Pass *True* if the message should be sent even if the specified replied-to message is not found
	  reply_markup                    InlineKeyboardMarkup    Optional   A JSON-serialized object for an inline keyboard. If empty, one 'Pay \`total price\`' button will be shown. If not empty, the first button must be a Pay button.
	EOF
    else
        curl --silent --location \
          --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendInvoice" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --data "${1:-{\}}"
    fi
}
