## GetPersonInfo # Information about one or more people
# /people

function GetPersonInfo ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Information about one or more people
	Ref: /people
	---
	API Base URI: \${opendcim_uri} (${opendcim_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[7mParamater       Input   Req.    Type     Description(B[m
	PersonID        query   false   string   A specific PersonID for a record to retrieve from the database
	UserID          query   false   string   A specific UserID for a record to retrieve from the database
	Email           query   false   string   A specific EmailAddress for a record to retrieve from the database
	
	[7mCode  Description(B[m
	200   successful operation
	401   Access denied.
	
	EOF
    else
        curl --silent --insecure --location --request GET --url "${opendcim_uri}/people" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
