## createNetworkAppliancePrefixesDelegatedStatic # Add a static delegated prefix from a network
# https://developer.cisco.com/meraki/api-v1/#!create-network-appliance-prefixes-delegated-static

function createNetworkAppliancePrefixesDelegatedStatic ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Add a static delegated prefix from a network
	Ref: https://developer.cisco.com/meraki/api-v1/#!create-network-appliance-prefixes-delegated-static
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	prefix: A static IPv6 prefix
	origin: The origin of the prefix
	description: A name or description for the prefix
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/appliance/prefixes/delegated/statics" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
