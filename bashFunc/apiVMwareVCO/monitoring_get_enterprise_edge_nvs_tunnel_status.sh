## monitoring_get_enterprise_edge_nvs_tunnel_status # Get state history for tunnels from Edge(s) to non-SD-WAN sites
# /monitoring/getEnterpriseEdgeNvsTunnelStatus

function monitoring_get_enterprise_edge_nvs_tunnel_status ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${vco_uri}" ]] || [[ ! -f "${HOME}/.cache/vco_auth.cookie" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get state history for tunnels from Edge(s) to non-SD-WAN sites
	Ref: /monitoring/getEnterpriseEdgeNvsTunnelStatus
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[3mParamater       Input   Req.    Type     Description[m
	body            body    true    false    
	
	[3mCode  Description[m
	200   Request was successfully processed
	400   null
	500   null
	
	EOF
    else
        curl --silent --insecure --location --request POST --url "${vco_uri}/monitoring/getEnterpriseEdgeNvsTunnelStatus" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/vco_auth.cookie" --data "${1:-{\}}"
    fi
}
