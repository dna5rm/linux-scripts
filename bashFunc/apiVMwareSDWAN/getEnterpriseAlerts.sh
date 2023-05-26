## getEnterpriseAlerts # Fetch past triggered alerts for the specified enterprise   
# /api/sdwan/v2/enterprises/{enterpriseLogicalId}/alerts

function getEnterpriseAlerts ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Fetch past triggered alerts for the specified enterprise   
	Ref: /api/sdwan/v2/enterprises/{enterpriseLogicalId}/alerts
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[7mParamater       Input   Req.    Type     Description(B[m
	enterpriseLogicalId path    true    false    The `logicalId` GUID for the target enterprise
	start           query   false   false    Query interval start time represented as a 13-digit, millisecond-precision epoch timestamp.
	end             query   false   false    Query interval end time represented as a 13-digit, millisecond-precision epoch timestamp.
	limit           query   false   false    Limits the maximum size of the result set.
	nextPageLink    query   false   false    A nextPageLink value, as fetched via a past call to a list API method. When a nextPageLink value is specified, any other query parameters that may ordinarily be used to sort or filter the result set are ignored.
	prevPageLink    query   false   false    A prevPageLink value, as fetched via a past call to a list API method. When a prevPageLink value is specified, any other query parameters that may ordinarily be used to sort or filter the result set are ignored.
	include         query   false   false    A comma-separated list of field names corresponding to linked resources. Where supported, the server will resolve resource attributes for the specified resources.
	edgeName[contains] query   false   false    Filter by edgeName[contains]
	edgeName[notContains] query   false   false    Filter by edgeName[notContains]
	linkName[contains] query   false   false    Filter by linkName[contains]
	linkName[notContains] query   false   false    Filter by linkName[notContains]
	type[is]        query   false   false    Filter by type[is]
	type[isNot]     query   false   false    Filter by type[isNot]
	type[in]        query   false   false    Filter by type[in]
	type[notIn]     query   false   false    Filter by type[notIn]
	state[is]       query   false   false    Filter by state[is]
	state[isNot]    query   false   false    Filter by state[isNot]
	state[in]       query   false   false    Filter by state[in]
	state[notIn]    query   false   false    Filter by state[notIn]
	enterpriseAlertConfigurationId[isNull] query   false   false    Filter by enterpriseAlertConfigurationId[isNull]
	enterpriseAlertConfigurationId[isNotNull] query   false   false    Filter by enterpriseAlertConfigurationId[isNotNull]
	
	[7mCode  Description(B[m
	200   Request successfully processed
	400   ValidationError
	401   Unauthorized
	404   Resource not found
	429   Rate Limit Exceeded
	500   Internal server error
	
	EOF
    else

        # Construct URL w/Query Parameters
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises/${1}/alerts" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${2:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request GET --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" 

    fi
}
