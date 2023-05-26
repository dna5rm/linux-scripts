## metrics_get_edge_flow_visibility_metrics # Get flow stats metric data for a given edge
# /metrics/getEdgeFlowVisibilityMetrics

function metrics_get_edge_flow_visibility_metrics ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${vco_uri}" ]] || [[ ! -f "/home/deaves/.cache/vco_auth.cookie" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get flow stats metric data for a given edge
	Ref: /metrics/getEdgeFlowVisibilityMetrics
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[7mParamater       Input   Req.    Type     Description(B[m
	body            body    true    false    
	
	[7mCode  Description(B[m
	200   Request was successfully processed
	400   null
	500   null
	
	EOF
    else
        curl --silent --insecure --location --request POST --url "${vco_uri}/metrics/getEdgeFlowVisibilityMetrics" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/vco_auth.cookie" --data "${1:-{\}}"
    fi
}
