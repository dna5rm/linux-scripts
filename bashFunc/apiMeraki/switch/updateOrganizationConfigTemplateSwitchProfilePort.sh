## updateOrganizationConfigTemplateSwitchProfilePort # Update a switch profile port
# https://developer.cisco.com/meraki/api-v1/#!update-organization-config-template-switch-profile-port

function updateOrganizationConfigTemplateSwitchProfilePort ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${5}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update a switch profile port
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-organization-config-template-switch-profile-port
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	organizationId: \${1} (${1:-required})
	configTemplateId: \${2} (${2:-required})
	profileId: \${3} (${3:-required})
	portId: \${4} (${4:-required})
	---
	name: The name of the switch profile port.
	tags: The list of tags of the switch profile port.
	enabled: The status of the switch profile port.
	poeEnabled: The PoE status of the switch profile port.
	type: The type of the switch profile port ('trunk' or 'access').
	vlan: The VLAN of the switch profile port. A null value will clear the value set for trunk ports.
	voiceVlan: The voice VLAN of the switch profile port. Only applicable to access ports.
	allowedVlans: The VLANs allowed on the switch profile port. Only applicable to trunk ports.
	isolationEnabled: The isolation status of the switch profile port.
	rstpEnabled: The rapid spanning tree protocol status.
	stpGuard: The state of the STP guard ('disabled', 'root guard', 'bpdu guard' or 'loop guard').
	linkNegotiation: The link speed for the switch profile port.
	portScheduleId: The ID of the port schedule. A value of null will clear the port schedule.
	udld: The action to take when Unidirectional Link is detected (Alert only, Enforce). Default configuration is Alert only.
	accessPolicyType: The type of the access policy of the switch profile port. Only applicable to access ports. Can be one of 'Open', 'Custom access policy', 'MAC allow list' or 'Sticky MAC allow list'.
	accessPolicyNumber: The number of a custom access policy to configure on the switch profile port. Only applicable when 'accessPolicyType' is 'Custom access policy'.
	macAllowList: Only devices with MAC addresses specified in this list will have access to this port. Up to 20 MAC addresses can be defined. Only applicable when 'accessPolicyType' is 'MAC allow list'.
	stickyMacAllowList: The initial list of MAC addresses for sticky Mac allow list. Only applicable when 'accessPolicyType' is 'Sticky MAC allow list'.
	stickyMacAllowListLimit: The maximum number of MAC addresses for sticky MAC allow list. Only applicable when 'accessPolicyType' is 'Sticky MAC allow list'.
	stormControlEnabled: The storm control status of the switch profile port.
	flexibleStackingEnabled: For supported switches (e.g. MS420/MS425), whether or not the port has flexible stacking enabled.
	daiTrusted: If true, ARP packets for this port will be considered trusted, and Dynamic ARP Inspection will allow the traffic.
	profile: Profile attributes
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/organizations/${1}/configTemplates/${2}/switch/profiles/${3}/ports/${4}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
