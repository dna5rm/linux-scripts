## getEnterpriseEvents # Fetch time-ordered list of events   
# /api/sdwan/v2/enterprises/{enterpriseLogicalId}/events

function getEnterpriseEvents ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Fetch time-ordered list of events   
	Ref: /api/sdwan/v2/enterprises/{enterpriseLogicalId}/events
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
	event[is]       query   false   false    Filter by event[is]
	event[isNot]    query   false   false    Filter by event[isNot]
	event[in]       query   false   false    Filter by event[in]
	event[notIn]    query   false   false    Filter by event[notIn]
	severity[is]    query   false   false    Filter by severity[is]
	severity[isNot] query   false   false    Filter by severity[isNot]
	severity[in]    query   false   false    Filter by severity[in]
	severity[notIn] query   false   false    Filter by severity[notIn]
	enterpriseUsername[is] query   false   false    Filter by enterpriseUsername[is]
	enterpriseUsername[isNot] query   false   false    Filter by enterpriseUsername[isNot]
	enterpriseUsername[isNull] query   false   false    Filter by enterpriseUsername[isNull]
	enterpriseUsername[isNotNull] query   false   false    Filter by enterpriseUsername[isNotNull]
	enterpriseUsername[startsWith] query   false   false    Filter by enterpriseUsername[startsWith]
	enterpriseUsername[notStartsWith] query   false   false    Filter by enterpriseUsername[notStartsWith]
	enterpriseUsername[endsWith] query   false   false    Filter by enterpriseUsername[endsWith]
	enterpriseUsername[notEndsWith] query   false   false    Filter by enterpriseUsername[notEndsWith]
	enterpriseUsername[contains] query   false   false    Filter by enterpriseUsername[contains]
	enterpriseUsername[notContains] query   false   false    Filter by enterpriseUsername[notContains]
	enterpriseUsername[in] query   false   false    Filter by enterpriseUsername[in]
	enterpriseUsername[notIn] query   false   false    Filter by enterpriseUsername[notIn]
	detail[is]      query   false   false    Filter by detail[is]
	detail[isNot]   query   false   false    Filter by detail[isNot]
	detail[isNull]  query   false   false    Filter by detail[isNull]
	detail[isNotNull] query   false   false    Filter by detail[isNotNull]
	detail[startsWith] query   false   false    Filter by detail[startsWith]
	detail[notStartsWith] query   false   false    Filter by detail[notStartsWith]
	detail[endsWith] query   false   false    Filter by detail[endsWith]
	detail[notEndsWith] query   false   false    Filter by detail[notEndsWith]
	detail[contains] query   false   false    Filter by detail[contains]
	detail[notContains] query   false   false    Filter by detail[notContains]
	detail[in]      query   false   false    Filter by detail[in]
	detail[notIn]   query   false   false    Filter by detail[notIn]
	segmentName[is] query   false   false    Filter by segmentName[is]
	segmentName[isNot] query   false   false    Filter by segmentName[isNot]
	segmentName[isNull] query   false   false    Filter by segmentName[isNull]
	segmentName[isNotNull] query   false   false    Filter by segmentName[isNotNull]
	segmentName[startsWith] query   false   false    Filter by segmentName[startsWith]
	segmentName[notStartsWith] query   false   false    Filter by segmentName[notStartsWith]
	segmentName[endsWith] query   false   false    Filter by segmentName[endsWith]
	segmentName[notEndsWith] query   false   false    Filter by segmentName[notEndsWith]
	segmentName[contains] query   false   false    Filter by segmentName[contains]
	segmentName[notContains] query   false   false    Filter by segmentName[notContains]
	segmentName[in] query   false   false    Filter by segmentName[in]
	segmentName[notIn] query   false   false    Filter by segmentName[notIn]
	message[is]     query   false   false    Filter by message[is]
	message[isNot]  query   false   false    Filter by message[isNot]
	message[isNull] query   false   false    Filter by message[isNull]
	message[isNotNull] query   false   false    Filter by message[isNotNull]
	message[startsWith] query   false   false    Filter by message[startsWith]
	message[notStartsWith] query   false   false    Filter by message[notStartsWith]
	message[endsWith] query   false   false    Filter by message[endsWith]
	message[notEndsWith] query   false   false    Filter by message[notEndsWith]
	message[contains] query   false   false    Filter by message[contains]
	message[notContains] query   false   false    Filter by message[notContains]
	message[in]     query   false   false    Filter by message[in]
	message[notIn]  query   false   false    Filter by message[notIn]
	edgeName[is]    query   false   false    Filter by edgeName[is]
	edgeName[isNot] query   false   false    Filter by edgeName[isNot]
	edgeName[isNull] query   false   false    Filter by edgeName[isNull]
	edgeName[isNotNull] query   false   false    Filter by edgeName[isNotNull]
	edgeName[startsWith] query   false   false    Filter by edgeName[startsWith]
	edgeName[notStartsWith] query   false   false    Filter by edgeName[notStartsWith]
	edgeName[endsWith] query   false   false    Filter by edgeName[endsWith]
	edgeName[notEndsWith] query   false   false    Filter by edgeName[notEndsWith]
	edgeName[contains] query   false   false    Filter by edgeName[contains]
	edgeName[notContains] query   false   false    Filter by edgeName[notContains]
	edgeName[in]    query   false   false    Filter by edgeName[in]
	edgeName[notIn] query   false   false    Filter by edgeName[notIn]
	
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
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises/${1}/events" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${2:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request GET --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" 

    fi
}
