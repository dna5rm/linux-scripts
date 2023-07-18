## Labeldetails(bylabeltype) # Label details (by label type)
# /groups/{type}/{groupId}.json

function getLabeldetails(bylabeltype) ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${thousandeyes_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${2}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Label details (by label type)
	Ref: /groups/{type}/{groupId}.json
	---
	API Base URI: \${thousandeyes_uri} (${thousandeyes_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	Authorization   header  false   string   
	Content-Type    header  true    string   
	type            path    true    string   
	groupId         path    true    string   
	
	[3mCode  Description[m
	200   
	
	EOF
    else
        curl --silent --insecure --location --request GET --url "${thousandeyes_uri}/groups/${1}/${2}" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${3:-{\}}"
    fi
}
