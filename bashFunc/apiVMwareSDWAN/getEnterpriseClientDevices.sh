## getEnterpriseClientDevices # Fetch all client devices   
# /api/sdwan/v2/enterprises/{enterpriseLogicalId}/clientDevices

function getEnterpriseClientDevices ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${vco_uri}" ]] || [[ ! -f "/home/deaves/.cache/vco_auth.cookie" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Fetch all client devices   
	Ref: /api/sdwan/v2/enterprises/{enterpriseLogicalId}/clientDevices
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[7mParamater       Input   Req.    Type     Description(B[m
	enterpriseLogicalId path    true    false    The `logicalId` GUID for the target enterprise
	include         query   false   false    A comma-separated list of field names corresponding to linked resources. Where supported, the server will resolve resource attributes for the specified resources.
	
	[7mCode  Description(B[m
	200   Request successfully processed
	401   Unauthorized
	404   Resource not found
	429   Rate Limit Exceeded
	500   Internal server error
	
	EOF
    else

        # Construct URL w/Query Parameters
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises/${1}/clientDevices" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${2:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request GET --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" 

    fi
}
