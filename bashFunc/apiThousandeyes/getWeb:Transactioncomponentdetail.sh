## Web:Transactioncomponentdetail # Web: Transaction component detail
# /web/transactions/{testId}/{agentId}/{roundId}/{pageNum}.json

function getWeb:Transactioncomponentdetail ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${thousandeyes_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${4}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Web: Transaction component detail
	Ref: /web/transactions/{testId}/{agentId}/{roundId}/{pageNum}.json
	---
	API Base URI: \${thousandeyes_uri} (${thousandeyes_uri:-required})
	Authorization Key: \${auth_key} (${auth_key:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	Authorization   header  false   string   
	Accept          header  true    string   
	testId          path    true    string   
	agentId         path    true    string   
	roundId         path    true    string   
	pageNum         path    true    string   
	
	[3mCode  Description[m
	200   
	
	EOF
    else
        curl --silent --insecure --location --request GET --url "${thousandeyes_uri}/web/transactions/${1}/${2}/${3}/${4}" \
          --header "Accept: application/json" \
          --header "Authorization: Basic ${auth_key}" \
          --header "Content-Type: application/json" \
          --data "${5:-{\}}"
    fi
}
