## getEdgePathSeries # Fetch path stats time series from an edge   
# /api/sdwan/v2/enterprises/{enterpriseLogicalId}/edges/{edgeLogicalId}/pathStats/timeSeries

function getEdgePathSeries ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${vco_uri}" ]] || [[ ! -f "/home/deaves/.cache/vco_auth.cookie" ]] || [[ -z "${4}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Fetch path stats time series from an edge   
	Ref: /api/sdwan/v2/enterprises/{enterpriseLogicalId}/edges/{edgeLogicalId}/pathStats/timeSeries
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[7mParamater       Input   Req.    Type     Description(B[m
	enterpriseLogicalId path    true    false    The `logicalId` GUID for the target enterprise
	edgeLogicalId   path    true    false    The `logicalId` GUID for the target edge
	include         query   false   false    A comma-separated list of field names corresponding to linked resources. Where supported, the server will resolve resource attributes for the specified resources.
	peerLogicalId   query   true    false    The `logicalId` GUID for the path stats peer
	start           query   false   false    Query interval start time represented as a 13-digit, millisecond-precision epoch timestamp.
	end             query   false   false    Query interval end time represented as a 13-digit, millisecond-precision epoch timestamp.
	maxSamples      query   false   false    An integer value specifying the max samples for path stats
	metrics         query   false   false    metrics supported for querying pathStats
	limit           query   false   false    Limits the maximum size of the result set.
	groupBy         query   false   false    groupBy criteria according to which the result set is grouped. For example, a groupBy value of link produces an API response wherein each element corresponds to a distinct link record for which aggregate values are reported.
	
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
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises/${1}/edges/${2}/pathStats/timeSeries" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${5:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request GET --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" 

    fi
}
