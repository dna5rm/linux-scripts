## Endpointscheduledtestdetails # Endpoint scheduled test details
# /endpoint-tests/{testId}.json

function getEndpointscheduledtestdetails ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Endpoint scheduled test details
	Ref: /endpoint-tests/{testId}.json
	---
	API Base URI: \${thousandeyes_uri} (${thousandeyes_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	Authorization   header  false   string   
	Content-Type    header  true    string   
	testId          path    true    string   
	
	[3mCode  Description[m
	200   
	
	EOF
    else
        curl --silent --insecure --location --request GET --url "${thousandeyes_uri}/endpoint-tests/${1}" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
