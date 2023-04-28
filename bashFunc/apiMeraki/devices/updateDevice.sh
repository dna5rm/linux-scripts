## updateDevice # Update the attributes of a device
# https://developer.cisco.com/meraki/api-v1/#!update-device

function updateDevice ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the attributes of a device
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-device
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	serial: \${1} (${1:-required})
	---
	name: The name of a device
	tags: The list of tags of a device
	lat: The latitude of a device
	lng: The longitude of a device
	address: The address of a device
	notes: The notes for the device. String. Limited to 255 characters.
	moveMapMarker: Whether or not to set the latitude and longitude of a device based on the new address. Only applies when lat and lng are not specified.
	switchProfileId: The ID of a switch profile to bind to the device (for available switch profiles, see the 'Switch Profiles' endpoint). Use null to unbind the switch device from the current profile. For a device to be bindable to a switch profile, it must (1) be a switch, and (2) belong to a network that is bound to a configuration template.
	floorPlanId: The floor plan to associate to this device. null disassociates the device from the floorplan.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/devices/${1}" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
