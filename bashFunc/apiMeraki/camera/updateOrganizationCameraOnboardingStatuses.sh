## updateOrganizationCameraOnboardingStatuses # Notify that credential handoff to camera has completed
# https://developer.cisco.com/meraki/api-v1/#!update-organization-camera-onboarding-statuses

function updateOrganizationCameraOnboardingStatuses ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Notify that credential handoff to camera has completed
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-organization-camera-onboarding-statuses
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	---
	serial: Serial of camera
	wirelessCredentialsSent: Note whether credentials were sent successfully
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/organizations/${1}/camera/onboarding/statuses" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
