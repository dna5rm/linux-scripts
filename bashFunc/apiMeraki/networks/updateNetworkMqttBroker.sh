## updateNetworkMqttBroker # Update an MQTT broker
# https://developer.cisco.com/meraki/api-v1/#!update-network-mqtt-broker

function updateNetworkMqttBroker ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${3}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update an MQTT broker
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-mqtt-broker
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	mqttBrokerId: \${2} (${2:-required})
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
          --request PUT --url "${meraki_uri}/networks/${1}/mqttBrokers/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
