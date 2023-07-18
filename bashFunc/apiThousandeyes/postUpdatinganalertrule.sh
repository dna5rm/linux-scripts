## Updatinganalertrule # Updating an alert rule
# /alert-rules/{ruleId}/update.json

function postUpdatinganalertrule ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${thousandeyes_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Updating an alert rule
	Ref: /alert-rules/{ruleId}/update.json
	---
	API Base URI: \${thousandeyes_uri} (${thousandeyes_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	Authorization   header  false   string   
	Content-Type    header  true    string   
	Body            body    true    false    
	ruleId          path    true    string   
	
	[3mCode  Description[m
	200   
	
	EOF
    else
        curl --silent --insecure --location --request POST --url "${thousandeyes_uri}/alert-rules/${1}/update.json" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
