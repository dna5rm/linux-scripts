## updateNetworkApplianceWarmSpare # Update MX warm spare settings
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-warm-spare

function updateNetworkApplianceWarmSpare ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update MX warm spare settings
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-warm-spare
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	enabled: Enable warm spare
	spareSerial: Serial number of the warm spare appliance
	uplinkMode: Uplink mode, either virtual or public
	virtualIp1: The WAN 1 shared IP
	virtualIp2: The WAN 2 shared IP
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/warmSpare" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
