## modifyNetworkSmDevicesTags # Add, delete, or update the tags of a set of devices
# https://developer.cisco.com/meraki/api-v1/#!modify-network-sm-devices-tags

function modifyNetworkSmDevicesTags ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Add, delete, or update the tags of a set of devices
	Ref: https://developer.cisco.com/meraki/api-v1/#!modify-network-sm-devices-tags
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	tags: The tags to be added, deleted, or updated.
	updateAction: One of add, delete, or update. Only devices that have been modified will be returned.
	wifiMacs: The wifiMacs of the devices to be modified.
	ids: The ids of the devices to be modified.
	serials: The serials of the devices to be modified.
	scope: The scope (one of all, none, withAny, withAll, withoutAny, or withoutAll) and a set of tags of the devices to be modified.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request POST --url "${meraki_uri}/networks/${1}/sm/devices/modifyTags" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
