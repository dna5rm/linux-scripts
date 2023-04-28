## getOrganizationCameraOnboardingStatuses # Fetch onboarding status of cameras
# https://developer.cisco.com/meraki/api-v1/#!get-organization-camera-onboarding-statuses

function getOrganizationCameraOnboardingStatuses ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Fetch onboarding status of cameras
	Ref: https://developer.cisco.com/meraki/api-v1/#!get-organization-camera-onboarding-statuses
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	serials: A list of serial numbers. The returned cameras will be filtered to only include these serials.
	networkIds: A list of network IDs. The returned cameras will be filtered to only include these networks.
	EOF
    else
         curl --silent --location \
          --request GET --url "${meraki_uri}/organizations/${1}/camera/onboarding/statuses" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}"
    fi
}
