## updateOrganizationSnmp # Update the SNMP settings for an organization
# https://developer.cisco.com/meraki/api-v1/#!update-organization-snmp

function updateOrganizationSnmp ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the SNMP settings for an organization
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-organization-snmp
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	v2cEnabled: Boolean indicating whether SNMP version 2c is enabled for the organization.
	v3Enabled: Boolean indicating whether SNMP version 3 is enabled for the organization.
	v3AuthMode: The SNMP version 3 authentication mode. Can be either 'MD5' or 'SHA'.
	v3AuthPass: The SNMP version 3 authentication password. Must be at least 8 characters if specified.
	v3PrivMode: The SNMP version 3 privacy mode. Can be either 'DES' or 'AES128'.
	v3PrivPass: The SNMP version 3 privacy password. Must be at least 8 characters if specified.
	peerIps: The list of IPv4 addresses that are allowed to access the SNMP server.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/organizations/${1}/snmp" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
