## getAdministeredIdentitiesMe # Returns the identity of the current user.
# https://developer.cisco.com/meraki/api-v1/#!get-administered-identities-me

function getAdministeredIdentitiesMe ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${0}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Returns the identity of the current user.
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-administered-identities-me
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/administered/identities/me" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
