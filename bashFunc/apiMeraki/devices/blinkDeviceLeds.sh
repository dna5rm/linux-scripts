## blinkDeviceLeds # Blink the LEDs on a device
# https://developer.cisco.com/meraki/api-v1/#!blink-device-leds

function blinkDeviceLeds ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Blink the LEDs on a device
	Ref: https://developer.cisco.com/meraki/api-v1/#!blink-device-leds
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	duration: The duration in seconds. Must be between 5 and 120. Default is 20 seconds
	period: The period in milliseconds. Must be between 100 and 1000. Default is 160 milliseconds
	duty: The duty cycle as the percent active. Must be between 10 and 90. Default is 50.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/devices/${1}/blinkLeds" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
