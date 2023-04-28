## updateNetworkMerakiAuthUser # Update a user configured with Meraki Authentication (currently, 802.1X RADIUS, splash guest, and client VPN users can be updated)
# https://developer.cisco.com/meraki/api-v1/#!update-network-meraki-auth-user

function updateNetworkMerakiAuthUser ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a user configured with Meraki Authentication (currently, 802.1X RADIUS, splash guest, and client VPN users can be updated)
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-meraki-auth-user
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	merakiAuthUserId: \${2} (${2:-required})
	---
	name: Name of the user. Only allowed If the user is not Dashboard administrator.
	password: The password for this user account. Only allowed If the user is not Dashboard administrator.
	emailPasswordToUser: Whether or not Meraki should email the password to user. Default is false.
	authorizations: Authorization zones and expiration dates for the user.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/merakiAuthUsers/${2}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
