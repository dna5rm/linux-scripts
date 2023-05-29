## updateEdge # Update an Edge   
# /api/sdwan/v2/enterprises/{enterpriseLogicalId}/edges/{edgeLogicalId}/

function updateEdge ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${vco_uri}" ]] || [[ ! -f "${HOME}/.cache/vco_auth.cookie" ]] || [[ -z "${2}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update an Edge   
	Ref: /api/sdwan/v2/enterprises/{enterpriseLogicalId}/edges/{edgeLogicalId}/
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[3mParamater       Input   Req.    Type     Description[m
	enterpriseLogicalId path    true    false    The `logicalId` GUID for the target enterprise
	edgeLogicalId   path    true    false    The `logicalId` GUID for the target edge
	include         query   false   false    A comma-separated list of field names corresponding to linked resources. Where supported, the server will resolve resource attributes for the specified resources.
	
	[3mCode  Description[m
	200   Request successfully processed
	400   ValidationError
	401   Unauthorized
	404   Resource not found
	415   UnsupportedMediaTypeError
	422   DataValidationError
	429   Rate Limit Exceeded
	500   Internal server error
	
	EOF
    else

        # Construct URL w/Query Parameters
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises/${1}/edges/${2}" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${3:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request PATCH --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" --data "${4:-{\}}"

    fi
}
