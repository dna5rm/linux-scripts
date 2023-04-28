## updateNetworkWirelessSsidIdentityPsk # Update an Identity PSK
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-identity-psk

function updateNetworkWirelessSsidIdentityPsk ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${4}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update an Identity PSK
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-identity-psk
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	identityPskId: \${3} (${3:-required})
	---
	name: The name of the Identity PSK
	passphrase: The passphrase for client authentication
	groupPolicyId: The group policy to be applied to clients
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/ssids/${2}/identityPsks/${3}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
