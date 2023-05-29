## getEnterpriseEdges # List Customer Edges   
# /api/sdwan/v2/enterprises/{enterpriseLogicalId}/edges/

function getEnterpriseEdges ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${vco_uri}" ]] || [[ ! -f "${HOME}/.cache/vco_auth.cookie" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List Customer Edges   
	Ref: /api/sdwan/v2/enterprises/{enterpriseLogicalId}/edges/
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[3mParamater       Input   Req.    Type     Description[m
	enterpriseLogicalId path    true    false    The `logicalId` GUID for the target enterprise
	include         query   false   false    A comma-separated list of field names corresponding to linked resources. Where supported, the server will resolve resource attributes for the specified resources.
	prevPageLink    query   false   false    A prevPageLink value, as fetched via a past call to a list API method. When a prevPageLink value is specified, any other query parameters that may ordinarily be used to sort or filter the result set are ignored.
	nextPageLink    query   false   false    A nextPageLink value, as fetched via a past call to a list API method. When a nextPageLink value is specified, any other query parameters that may ordinarily be used to sort or filter the result set are ignored.
	limit           query   false   false    Limits the maximum size of the result set.
	sortBy          query   false   false    sortBy query param to sort the resultset. Format of sortBy is <attribute><ASC | DESC>
	name[is]        query   false   false    Filter by name[is]
	name[isNot]     query   false   false    Filter by name[isNot]
	name[isNull]    query   false   false    Filter by name[isNull]
	name[isNotNull] query   false   false    Filter by name[isNotNull]
	name[startsWith] query   false   false    Filter by name[startsWith]
	name[notStartsWith] query   false   false    Filter by name[notStartsWith]
	name[endsWith]  query   false   false    Filter by name[endsWith]
	name[notEndsWith] query   false   false    Filter by name[notEndsWith]
	name[contains]  query   false   false    Filter by name[contains]
	name[notContains] query   false   false    Filter by name[notContains]
	name[in]        query   false   false    Filter by name[in]
	name[notIn]     query   false   false    Filter by name[notIn]
	created[is]     query   false   false    Filter by created[is]
	created[isNot]  query   false   false    Filter by created[isNot]
	created[isNull] query   false   false    Filter by created[isNull]
	created[isNotNull] query   false   false    Filter by created[isNotNull]
	created[greaterOrEquals] query   false   false    Filter by created[greaterOrEquals]
	created[lesserOrEquals] query   false   false    Filter by created[lesserOrEquals]
	created[in]     query   false   false    Filter by created[in]
	created[notIn]  query   false   false    Filter by created[notIn]
	activationState[is] query   false   false    Filter by activationState[is]
	activationState[isNot] query   false   false    Filter by activationState[isNot]
	activationState[in] query   false   false    Filter by activationState[in]
	activationState[notIn] query   false   false    Filter by activationState[notIn]
	modelNumber[is] query   false   false    Filter by modelNumber[is]
	modelNumber[isNot] query   false   false    Filter by modelNumber[isNot]
	modelNumber[in] query   false   false    Filter by modelNumber[in]
	modelNumber[notIn] query   false   false    Filter by modelNumber[notIn]
	edgeState[is]   query   false   false    Filter by edgeState[is]
	edgeState[isNot] query   false   false    Filter by edgeState[isNot]
	edgeState[in]   query   false   false    Filter by edgeState[in]
	edgeState[notIn] query   false   false    Filter by edgeState[notIn]
	buildNumber[is] query   false   false    Filter by buildNumber[is]
	buildNumber[isNot] query   false   false    Filter by buildNumber[isNot]
	buildNumber[isNull] query   false   false    Filter by buildNumber[isNull]
	buildNumber[isNotNull] query   false   false    Filter by buildNumber[isNotNull]
	buildNumber[startsWith] query   false   false    Filter by buildNumber[startsWith]
	buildNumber[notStartsWith] query   false   false    Filter by buildNumber[notStartsWith]
	buildNumber[endsWith] query   false   false    Filter by buildNumber[endsWith]
	buildNumber[notEndsWith] query   false   false    Filter by buildNumber[notEndsWith]
	buildNumber[contains] query   false   false    Filter by buildNumber[contains]
	buildNumber[notContains] query   false   false    Filter by buildNumber[notContains]
	buildNumber[in] query   false   false    Filter by buildNumber[in]
	buildNumber[notIn] query   false   false    Filter by buildNumber[notIn]
	softwareVersion[is] query   false   false    Filter by softwareVersion[is]
	softwareVersion[isNot] query   false   false    Filter by softwareVersion[isNot]
	softwareVersion[isNull] query   false   false    Filter by softwareVersion[isNull]
	softwareVersion[isNotNull] query   false   false    Filter by softwareVersion[isNotNull]
	softwareVersion[startsWith] query   false   false    Filter by softwareVersion[startsWith]
	softwareVersion[notStartsWith] query   false   false    Filter by softwareVersion[notStartsWith]
	softwareVersion[endsWith] query   false   false    Filter by softwareVersion[endsWith]
	softwareVersion[notEndsWith] query   false   false    Filter by softwareVersion[notEndsWith]
	softwareVersion[contains] query   false   false    Filter by softwareVersion[contains]
	softwareVersion[notContains] query   false   false    Filter by softwareVersion[notContains]
	softwareVersion[in] query   false   false    Filter by softwareVersion[in]
	softwareVersion[notIn] query   false   false    Filter by softwareVersion[notIn]
	serialNumber[is] query   false   false    Filter by serialNumber[is]
	serialNumber[isNot] query   false   false    Filter by serialNumber[isNot]
	serialNumber[isNull] query   false   false    Filter by serialNumber[isNull]
	serialNumber[isNotNull] query   false   false    Filter by serialNumber[isNotNull]
	serialNumber[startsWith] query   false   false    Filter by serialNumber[startsWith]
	serialNumber[notStartsWith] query   false   false    Filter by serialNumber[notStartsWith]
	serialNumber[endsWith] query   false   false    Filter by serialNumber[endsWith]
	serialNumber[notEndsWith] query   false   false    Filter by serialNumber[notEndsWith]
	serialNumber[contains] query   false   false    Filter by serialNumber[contains]
	serialNumber[notContains] query   false   false    Filter by serialNumber[notContains]
	serialNumber[in] query   false   false    Filter by serialNumber[in]
	serialNumber[notIn] query   false   false    Filter by serialNumber[notIn]
	softwareUpdated[is] query   false   false    Filter by softwareUpdated[is]
	softwareUpdated[isNot] query   false   false    Filter by softwareUpdated[isNot]
	softwareUpdated[isNull] query   false   false    Filter by softwareUpdated[isNull]
	softwareUpdated[isNotNull] query   false   false    Filter by softwareUpdated[isNotNull]
	softwareUpdated[greaterOrEquals] query   false   false    Filter by softwareUpdated[greaterOrEquals]
	softwareUpdated[lesserOrEquals] query   false   false    Filter by softwareUpdated[lesserOrEquals]
	softwareUpdated[in] query   false   false    Filter by softwareUpdated[in]
	softwareUpdated[notIn] query   false   false    Filter by softwareUpdated[notIn]
	customInfo[is]  query   false   false    Filter by customInfo[is]
	customInfo[isNot] query   false   false    Filter by customInfo[isNot]
	customInfo[isNull] query   false   false    Filter by customInfo[isNull]
	customInfo[isNotNull] query   false   false    Filter by customInfo[isNotNull]
	customInfo[startsWith] query   false   false    Filter by customInfo[startsWith]
	customInfo[notStartsWith] query   false   false    Filter by customInfo[notStartsWith]
	customInfo[endsWith] query   false   false    Filter by customInfo[endsWith]
	customInfo[notEndsWith] query   false   false    Filter by customInfo[notEndsWith]
	customInfo[contains] query   false   false    Filter by customInfo[contains]
	customInfo[notContains] query   false   false    Filter by customInfo[notContains]
	customInfo[in]  query   false   false    Filter by customInfo[in]
	customInfo[notIn] query   false   false    Filter by customInfo[notIn]
	
	[3mCode  Description[m
	200   Request successfully processed
	400   ValidationError
	401   Unauthorized
	404   Resource not found
	429   Rate Limit Exceeded
	500   Internal server error
	
	EOF
    else

        # Construct URL w/Query Parameters
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises/${1}/edges" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${2:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request GET --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" 

    fi
}
