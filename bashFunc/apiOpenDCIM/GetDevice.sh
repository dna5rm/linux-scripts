## GetDevice # Information about one or more devices
# /device

function GetDevice ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${opendcim_uri}" ]] || [[ -z "${auth_key}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Information about one or more devices
	Ref: /device
	---
	API Base URI: \${opendcim_uri} (${opendcim_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[7mParamater       Input   Req.    Type     Description(B[m
	DeviceID        query   false   string   A specific DeviceID for a record to retrieve from the database
	Cabinet         query   false   string   Filter results to those that match the given keyValue.  A value of -1 retrieves items in the virtual StorageRoom.
	Position        query   false   string   Search for the device in a specific position.   For virtual StorageRoom items, pass the DataCenterID in this value.
	DataCenterID    query   false   string   Filter results to those that match the given keyValue (does not work for StorageRoom - see note for Position).
	CabRowID        query   false   string   Filter results to those that match the given keyValue
	ZoneID          query   false   string   Filter results to those that match the given keyValue
	
	[7mCode  Description(B[m
	200   successful operation
	401   Access denied.
	
	EOF
    else
        curl --silent --insecure --location --request GET --url "${opendcim_uri}/device" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
