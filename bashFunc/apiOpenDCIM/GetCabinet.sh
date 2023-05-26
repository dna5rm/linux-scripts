## GetCabinet # Information about one or more cabinets
# /cabinet

function GetCabinet ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Information about one or more cabinets
	Ref: /cabinet
	---
	API Base URI: \${opendcim_uri} (${opendcim_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[7mParamater       Input   Req.    Type     Description(B[m
	CabinetID       query   false   string   A specific CabinetID for a record to retrieve from the database
	DataCenterID    query   false   string   A specific DataCenterID to filter results by
	CabRowID        query   false   string   A specific CabRowID to filter results by
	ZoneID          query   false   string   A specific ZoneID to filter results by
	
	[7mCode  Description(B[m
	200   successful operation
	401   Access denied.
	
	EOF
    else
        curl --silent --insecure --location --request GET --url "${opendcim_uri}/cabinet" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
