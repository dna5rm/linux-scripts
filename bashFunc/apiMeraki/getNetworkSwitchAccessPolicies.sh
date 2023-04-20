## Get Network Switch Access Policies
# List the access policies for a switch network. Only returns access policies with 'my RADIUS server' as authentication method
#
# Ref: https://developer.cisco.com/meraki/api-latest/#!get-network-switch-access-policies

function getNetworkSwitchAccessPolicies ()
{
    # Verify function requirements
    for req in curl
     do type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - ${req} is not installed. Aborting."
        exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${1}" ]]; then
	cat  <<-EOF
	$(basename "${0}"):${FUNCNAME[0]} - Missing Variable or Input...
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-missing})
	API Authorization Key: \${auth_key} (${auth_key:-missing})
	Network ID: \${1} (${1:-missing})
	EOF
    else
	curl --silent --location --request GET --url "${meraki_uri}/networks/${1}/switch/accessPolicies" --header "Content-Type: application/json" --header "Accept: application/json" --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
