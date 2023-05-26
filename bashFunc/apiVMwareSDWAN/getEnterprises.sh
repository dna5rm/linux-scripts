## getEnterprises # List Customers   
# /api/sdwan/v2/enterprises/

function getEnterprises ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List Customers   
	Ref: /api/sdwan/v2/enterprises/
	---
	API Base URI: \${vco_uri} (${vco_uri:-required})
	Authentication Cookie: login_enterprise_login.sh ($(test -f "${HOME}/.cache/vco_auth.cookie" && echo "present" || echo "missing"))
	
	[7mParamater       Input   Req.    Type     Description(B[m
	include         query   false   false    A comma-separated list of field names corresponding to linked resources. Where supported, the server will resolve resource attributes for the specified resources.
	prevPageLink    query   false   false    A prevPageLink value, as fetched via a past call to a list API method. When a prevPageLink value is specified, any other query parameters that may ordinarily be used to sort or filter the result set are ignored.
	nextPageLink    query   false   false    A nextPageLink value, as fetched via a past call to a list API method. When a nextPageLink value is specified, any other query parameters that may ordinarily be used to sort or filter the result set are ignored.
	limit           query   false   false    Limits the maximum size of the result set.
	sortBy          query   false   false    sortBy query param to sort the resultset. Format of sortBy is <attribute><ASC | DESC>
	name[contains]  query   false   false    Filter by name[contains]
	name[notContains] query   false   false    Filter by name[notContains]
	accountNumber[contains] query   false   false    Filter by accountNumber[contains]
	accountNumber[notContains] query   false   false    Filter by accountNumber[notContains]
	domain[contains] query   false   false    Filter by domain[contains]
	domain[notContains] query   false   false    Filter by domain[notContains]
	
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
        url=( "${vco_uri%/*/*}/api/sdwan/v2/enterprises" )
        url+=( `jq -r 'to_entries[] | "\(.key)=\(.value|@text|@uri)"' <<<"${1:-{\}}" | sed 's/[$]/\\&/g'` )

        curl --silent --insecure --location --request GET --url "$(sed 's/\ /?/;s/\ /\&/g' <<<${url[@]})" \
          --header "Content-Type: application/json" --cookie "${HOME}/.cache/vco_auth.cookie" 

    fi
}
