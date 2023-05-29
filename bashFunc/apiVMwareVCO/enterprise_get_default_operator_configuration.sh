## enterprise_get_default_operator_configuration # Gets the default operator configration for an enterprise
# /enterprise/getEnterpriseDefaultOperatorConfiguration

function enterprise_get_default_operator_configuration ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Gets the default operator configration for an enterprise
	Ref: /enterprise/getEnterpriseDefaultOperatorConfiguration
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
        curl --silent --insecure --location --request POST --url "${vco_uri}/enterprise/getEnterpriseDefaultOperatorConfiguration" \
          --header "Content-Type: application/json" \
          --cookie "${HOME}/.cache/vco_auth.cookie" --data "${1:-{\}}"
    fi
}
