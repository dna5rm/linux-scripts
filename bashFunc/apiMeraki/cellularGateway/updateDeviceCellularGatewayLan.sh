## updateDeviceCellularGatewayLan # Update the LAN Settings for a single MG.
# https://developer.cisco.com/meraki/api-v1/#!update-device-cellular-gateway-lan

function updateDeviceCellularGatewayLan ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the LAN Settings for a single MG.
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-device-cellular-gateway-lan
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	reservedIpRanges: list of all reserved IP ranges for a single MG
	fixedIpAssignments: list of all fixed IP assignments for a single MG
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/devices/${1}/cellularGateway/lan" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
