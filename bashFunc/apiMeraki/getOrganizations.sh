## Get Organizations
# List the organizations that the user has privileges on
#
# Ref: https://developer.cisco.com/meraki/api-v1/#!get-organizations

function getOrganizations ()
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
	EOF
    else
	curl --silent --location --request GET --url "${meraki_uri}/organizations" --header "Content-Type: application/json" --header "Accept: application/json" --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
