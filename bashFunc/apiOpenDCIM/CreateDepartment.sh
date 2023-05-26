## CreateDepartment # Create a new Department record in the database
# /department/{DepartmentName}

function CreateDepartment ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${opendcim_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create a new Department record in the database
	Ref: /department/{DepartmentName}
	---
	API Base URI: \${opendcim_uri} (${opendcim_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[7mParamater       Input   Req.    Type     Description(B[m
	DepartmentName  path    true    string   DepartmentName must be URL encoded.   Other properties are sent within the body in JSON format.
	body            body    true    false    
	
	[7mCode  Description(B[m
	200   successful operation
	401   Access denied.
	
	EOF
    else
        curl --silent --insecure --location --request PUT --url "${opendcim_uri}/department/${1}" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
