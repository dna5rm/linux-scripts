## getApplicationMapApplication # [OPERATOR ONLY] Fetch an application definition for the target application map   
# /api/sdwan/v2/applicationMaps/{logicalId}/applications/{appId}

function getApplicationMapApplication ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - [OPERATOR ONLY] Fetch an application definition for the target application map   
	Ref: /api/sdwan/v2/applicationMaps/{logicalId}/applications/{appId}
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[3mParamater       Input   Req.    Type     Description[m
	logicalId       path    true    false    The `logicalId` GUID for the target resource
	include         query   false   false    A comma-separated list of field names corresponding to linked resources. Where supported, the server will resolve resource attributes for the specified resources.
	appId           path    true    false    The `appId` for the target application
	
	[3mCode  Description[m
	200   Request successfully processed
	401   Unauthorized
	404   Resource not found
	429   Rate Limit Exceeded
	500   Internal server error
	
	EOF
    else

        # Construct URL w/Query Parameters
        url=( "${vco_uri%/*/*}/api/sdwan/v2/applicationMaps/${1}/applications/${2}" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${3:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request GET --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" 

    fi
}
