## getNetworkSplashLoginAttempts # List the splash login attempts for a network
# https://developer.cisco.com/meraki/api-v1/#!get-network-splash-login-attempts

function getNetworkSplashLoginAttempts ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the splash login attempts for a network
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-splash-login-attempts
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	ssidNumber: Only return the login attempts for the specified SSID
	loginIdentifier: The username, email, or phone number used during login
	timespan: The timespan, in seconds, for the login attempts. The period will be from [timespan] seconds ago until now. The maximum timespan is 3 months
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/splashLoginAttempts" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
