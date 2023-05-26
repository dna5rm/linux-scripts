## GetDeviceTemplate # Template information for devices.   Some of the properties are contextual and are not returned for all devices.
# /devicetemplate

function GetDeviceTemplate ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Template information for devices.   Some of the properties are contextual and are not returned for all devices.
	Ref: /devicetemplate
	---
	API Base URI: \${opendcim_uri} (${opendcim_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[7mParamater       Input   Req.    Type     Description(B[m
	TemplateID      query   false   string   A specific TemplateID for a record to retrieve from the database
	ManufacturerID  query   false   string   A specific ManufacturerID to filter results from the database
	
	[7mCode  Description(B[m
	200   successful operation
	401   Access denied.
	
	EOF
    else
        curl --silent --insecure --location --request GET --url "${opendcim_uri}/devicetemplate" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
