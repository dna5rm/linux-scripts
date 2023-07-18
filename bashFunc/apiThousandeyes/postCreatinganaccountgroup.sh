## Creatinganaccountgroup # Creating an account group
# /account-groups/new.json

function postCreatinganaccountgroup ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${thousandeyes_uri}" ]] || [[ -z "${auth_key}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Creating an account group
	Ref: /account-groups/new.json
	---
	API Base URI: \${thousandeyes_uri} (${thousandeyes_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	Authorization   header  false   string   
	Content-Type    header  true    string   
	Accept          header  true    string   
	Body            body    true    false    
	
	[3mCode  Description[m
	200   
	
	EOF
    else
        curl --silent --insecure --location --request POST --url "${thousandeyes_uri}/account-groups/new.json" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
