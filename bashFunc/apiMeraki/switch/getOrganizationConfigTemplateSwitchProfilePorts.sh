## getOrganizationConfigTemplateSwitchProfilePorts # Return all the ports of a switch profile
# https://developer.cisco.com/meraki/api-v1/#!get-organization-config-template-switch-profile-ports

function getOrganizationConfigTemplateSwitchProfilePorts ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Return all the ports of a switch profile
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-config-template-switch-profile-ports
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	configTemplateId: \${2} (${2:-required})
	profileId: \${3} (${3:-required})
	---
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/configTemplates/${2}/switch/profiles/${3}/ports" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
