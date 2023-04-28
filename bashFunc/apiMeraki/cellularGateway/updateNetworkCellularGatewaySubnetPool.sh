## updateNetworkCellularGatewaySubnetPool # Update the subnet pool and mask configuration for MGs in the network.
# https://developer.cisco.com/meraki/api-v1/#!update-network-cellular-gateway-subnet-pool

function updateNetworkCellularGatewaySubnetPool ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the subnet pool and mask configuration for MGs in the network.
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-cellular-gateway-subnet-pool
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	mask: Mask used for the subnet of all MGs in  this network.
	cidr: CIDR of the pool of subnets. Each MG in this network will automatically pick a subnet from this pool.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/cellularGateway/subnetPool" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
