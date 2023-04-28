## createNetworkMqttBroker # Add an MQTT broker
# https://developer.cisco.com/meraki/api-v1/#!create-network-mqtt-broker

function createNetworkMqttBroker ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Add an MQTT broker
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-mqtt-broker
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	name: Name of the MQTT broker.
	host: Host name/IP address where the MQTT broker runs.
	port: Host port though which the MQTT broker can be reached.
	security: Security settings of the MQTT broker.
	authentication: Authentication settings of the MQTT broker
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/mqttBrokers" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
