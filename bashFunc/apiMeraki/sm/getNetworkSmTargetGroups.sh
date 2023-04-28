## getNetworkSmTargetGroups # List the target groups in this network
# https://developer.cisco.com/meraki/api-v1/#!get-network-sm-target-groups

function getNetworkSmTargetGroups ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the target groups in this network
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-network-sm-target-groups
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	withDetails: Boolean indicating if the the ids of the devices or users scoped by the target group should be included in the response
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/networks/${1}/sm/targetGroups" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
