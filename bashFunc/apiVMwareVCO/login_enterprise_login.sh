## login_enterprise_login # Authenticate enterprise or partner (MSP) user
# /login/enterpriseLogin

function login_enterprise_login ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${vco_uri}" ]] || [[ -z "${vco_auth}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Authenticate enterprise or partner (MSP) user
	Ref: /login/enterpriseLogin
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Auth Username/Password: \${vco_auth} (${vco_auth:-required})
	
	[7mParamater       Input   Req.    Type     Description(B[m
	false           false                    
	
	[7mCode  Description(B[m
	200   If you are using an HTTP client that is configured to automatically follow HTTP redirects (e.g. Postman), a successful authentication request will cause your client to follow an HTTP 302 redirect to the portal 'Home' web page. Your session cookie may then be used to make API calls.
	302   An HTTP 302 response is returned on both successful and failed authentication attempts. If the response includes a Set-Cookie header specifying a non-empty velocloud.session cookie, authentication was successful and this cookie may be used to make API calls.
	
	EOF
    elif [[ ! -f "${HOME}/.cache/vco_auth.cookie" ]]; then
        curl --silent --insecure --location --request POST --url "${vco_uri}//login/enterpriseLogin" \
          --header "Content-Type: application/json" \
          --cookie-jar "${HOME}/.cache/vco_auth.cookie" --data "${vco_auth:-{\}}"
    fi
}
