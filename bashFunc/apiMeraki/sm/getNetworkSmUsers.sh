## getNetworkSmUsers # List the owners in an SM network with various specified fields and filters
# https://developer.cisco.com/meraki/api-v1/#!get-network-sm-users

function getNetworkSmUsers ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the owners in an SM network with various specified fields and filters
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-sm-users
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	ids: Filter users by id(s).
	usernames: Filter users by username(s).
	emails: Filter users by email(s).
	scope: Specifiy a scope (one of all, none, withAny, withAll, withoutAny, withoutAll) and a set of tags.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/sm/users" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
