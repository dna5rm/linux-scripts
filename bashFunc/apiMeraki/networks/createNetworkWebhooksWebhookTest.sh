## createNetworkWebhooksWebhookTest # Send a test webhook for a network
# https://developer.cisco.com/meraki/api-v1/#!create-network-webhooks-webhook-test

function createNetworkWebhooksWebhookTest ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${2}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Send a test webhook for a network
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-webhooks-webhook-test
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	url: The URL where the test webhook will be sent
	sharedSecret: The shared secret the test webhook will send. Optional. Defaults to an empty string.
	payloadTemplateId: The ID of the payload template of the test webhook. Defaults to the HTTP server's template ID if one exists for the given URL, or Generic template ID otherwise
	payloadTemplateName: The name of the payload template.
	alertTypeId: The type of alert which the test webhook will send. Optional. Defaults to power_supply_down.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/webhooks/webhookTests" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
