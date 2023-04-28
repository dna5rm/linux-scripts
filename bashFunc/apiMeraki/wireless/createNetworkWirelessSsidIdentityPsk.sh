## createNetworkWirelessSsidIdentityPsk # Create an Identity PSK
# https://developer.cisco.com/meraki/api-v1/#!create-network-wireless-ssid-identity-psk

function createNetworkWirelessSsidIdentityPsk ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create an Identity PSK
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-wireless-ssid-identity-psk
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	---
	name: The name of the Identity PSK
	groupPolicyId: The group policy to be applied to clients
	passphrase: The passphrase for client authentication. If left blank, one will be auto-generated.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/wireless/ssids/${2}/identityPsks" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
