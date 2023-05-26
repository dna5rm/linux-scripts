## list-blocks # List Block storages
# /blocks

function list-blocks ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${VULTR_API_URI}" ]] || [[ -z "${VULTR_API_KEY}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List all Block Storage in your account.
	Ref: /blocks
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	per_page        query   false   false    of items requested per page. Default is 100 and Max is 500.
	cursor          query   false   false    for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
	
	[3mCode  Description[m
	200   OK
	400   Bad Request
	401   Unauthorized
	500   Internal Server Error
	
	EOF
    else
        curl --silent --location --request GET --url "${VULTR_API_URI}/blocks" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
