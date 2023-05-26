## logout # Logout and invalidate authorization session cookie
# /logout

function logout ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Logout and invalidate authorization session cookie
	Ref: /logout
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	
	[7mParamater       Input   Req.    Type     Description(B[m
	
	[7mCode  Description(B[m
	200   If you are using an HTTP client that is configured to automatically follow HTTP redirects (e.g. Postman), a successful logout request will cause your client to follow an HTTP 302 redirect to the portal login web page.
	302   An HTTP 302 (redirect) response is returned on both successful and failed logout attempts.
	
	EOF
    else
        # Invalidate the session cookie.
        curl --silent --insecure --location --request POST --url "${vco_uri}//logout" \
          --header "Content-Type: application/json" \
          --cookie-jar "${HOME}/.cache/vco_auth.cookie" --data "${vco_auth:-{\}}"

        # Delete the stale session cookie.
        [[ -f "${HOME}/.cache/vco_auth.cookie" ]] && {
            rm "${HOME}/.cache/vco_auth.cookie"
        }
    fi
}
