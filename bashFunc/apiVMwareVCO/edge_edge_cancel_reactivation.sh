## edge_edge_cancel_reactivation # Cancel pending Edge reactivation request
# /edge/edgeCancelReactivation

function edge_edge_cancel_reactivation ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Cancel pending Edge reactivation request
	Ref: /edge/edgeCancelReactivation
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
        curl --silent --insecure --location --request POST --url "${vco_uri}/edge/edgeCancelReactivation" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/vco_auth.cookie" --data "${1:-{\}}"
    fi
}
