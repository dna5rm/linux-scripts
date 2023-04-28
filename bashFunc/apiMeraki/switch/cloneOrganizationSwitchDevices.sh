## cloneOrganizationSwitchDevices # Clone port-level and some switch-level configuration settings from a source switch to one or more target switches
# https://developer.cisco.com/meraki/api-v1/#!clone-organization-switch-devices

function cloneOrganizationSwitchDevices ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Clone port-level and some switch-level configuration settings from a source switch to one or more target switches
	Ref: https://developer.cisco.com/meraki/api-v1/#!clone-organization-switch-devices
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	sourceSerial: Serial number of the source switch (must be on a network not bound to a template)
	targetSerials: Array of serial numbers of one or more target switches (must be on a network not bound to a template)
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/organizations/${1}/switch/devices/clone" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
