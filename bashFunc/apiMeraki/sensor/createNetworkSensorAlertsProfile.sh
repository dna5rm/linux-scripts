## createNetworkSensorAlertsProfile # Creates a sensor alert profile for a network.
# https://developer.cisco.com/meraki/api-v1/#!create-network-sensor-alerts-profile

function createNetworkSensorAlertsProfile ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Creates a sensor alert profile for a network.
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-sensor-alerts-profile
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	name: Name of the sensor alert profile.
	conditions: List of conditions that will cause the profile to send an alert.
	schedule: The sensor schedule to use with the alert profile.
	recipients: List of recipients that will recieve the alert.
	serials: List of device serials assigned to this sensor alert profile.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/sensor/alerts/profiles" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
