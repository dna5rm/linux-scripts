## updateEnterpriseProfileDeviceSettings # Profile deviceSettings module update spec   Note: By default this API operation executes asynchronously, meaning successful requests to this method will return an HTTP 202 response including tracking resource information (incl. an HTTP Location header with a value like `/api/sdwan/v2/asyncOperations/4f951593-aff8-4f3c-9855-10fa5d32a419`). Due to a limitation of our documentation automation/tooling, we can only describe non-async API behavior, we are working on this and will update the expected behavior soon
# /api/sdwan/v2/enterprises/{enterpriseLogicalId}/profiles/{profileLogicalId}/deviceSettings

function updateEnterpriseProfileDeviceSettings ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Profile deviceSettings module update spec   Note: By default this API operation executes asynchronously, meaning successful requests to this method will return an HTTP 202 response including tracking resource information (incl. an HTTP Location header with a value like `/api/sdwan/v2/asyncOperations/4f951593-aff8-4f3c-9855-10fa5d32a419`). Due to a limitation of our documentation automation/tooling, we can only describe non-async API behavior, we are working on this and will update the expected behavior soon
	Ref: /api/sdwan/v2/enterprises/{enterpriseLogicalId}/profiles/{profileLogicalId}/deviceSettings
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[3mParamater       Input   Req.    Type     Description[m
	enterpriseLogicalId path    true    false    The `logicalId` GUID for the target enterprise
	profileLogicalId path    true    false    The `logicalId` GUID for the target profile
	
	[3mCode  Description[m
	200   Request successfully processed
	400   ValidationError
	401   Unauthorized
	404   Resource not found
	415   UnsupportedMediaTypeError
	429   Rate Limit Exceeded
	500   Internal server error
	
	EOF
    else

        # Construct URL w/Query Parameters
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises/${1}/profiles/${2}/deviceSettings" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${3:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request PATCH --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" --data "${4:-{\}}"

    fi
}
