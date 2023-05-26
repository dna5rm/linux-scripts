## getEdgeNonSdwanTunnelStatusViaEdge # Fetch Edge non-SD-WAN tunnel status   
# /api/sdwan/v2/enterprises/{enterpriseLogicalId}/edges/{edgeLogicalId}/nonSdWanTunnelStatus

function getEdgeNonSdwanTunnelStatusViaEdge ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${vco_uri}" ]] || [[ ! -f "/home/deaves/.cache/vco_auth.cookie" ]] || [[ -z "${2}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Fetch Edge non-SD-WAN tunnel status   
	Ref: /api/sdwan/v2/enterprises/{enterpriseLogicalId}/edges/{edgeLogicalId}/nonSdWanTunnelStatus
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[7mParamater       Input   Req.    Type     Description(B[m
	enterpriseLogicalId path    true    false    The `logicalId` GUID for the target enterprise
	edgeLogicalId   path    true    false    The `logicalId` GUID for the target edge
	include         query   false   false    A comma-separated list of field names corresponding to linked resources. Where supported, the server will resolve resource attributes for the specified resources.
	sortBy          query   false   false    sortBy query param to sort the resultset. Format of sortBy is <attribute><ASC | DESC>
	start           query   false   false    Query interval start time represented as a 13-digit, millisecond-precision epoch timestamp.
	end             query   false   false    Query interval end time represented as a 13-digit, millisecond-precision epoch timestamp.
	prevPageLink    query   false   false    A prevPageLink value, as fetched via a past call to a list API method. When a prevPageLink value is specified, any other query parameters that may ordinarily be used to sort or filter the result set are ignored.
	nextPageLink    query   false   false    A nextPageLink value, as fetched via a past call to a list API method. When a nextPageLink value is specified, any other query parameters that may ordinarily be used to sort or filter the result set are ignored.
	limit           query   false   false    Limits the maximum size of the result set.
	state[is]       query   false   false    Filter by state[is]
	state[isNot]    query   false   false    Filter by state[isNot]
	state[in]       query   false   false    Filter by state[in]
	state[notIn]    query   false   false    Filter by state[notIn]
	
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
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises/${1}/edges/${2}/nonSdWanTunnelStatus" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${3:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request GET --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" 

    fi
}
