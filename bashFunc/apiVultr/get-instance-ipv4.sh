## get-instance-ipv4 # List Instance IPv4 Information
# /instances/{instance-id}/ipv4

function get-instance-ipv4 ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${VULTR_API_URI}" ]] || [[ -z "${VULTR_API_KEY}" ]] || [[ -z "${1}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - List the IPv4 information for an Instance.
	Ref: /instances/{instance-id}/ipv4
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	public_network  query   false   false    `true`, includes information about the public network adapter (such as MAC address) with the `main_ip` entry.
	per_page        query   false   false    of items requested per page. Default is 100 and Max is 500.n
	cursor          query   false   false    for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
	
	[3mCode  Description[m
	200   OK
	400   Bad Request
	401   Unauthorized
	404   Not Found
	
	EOF
    else
        curl --silent --location --request GET --url "${VULTR_API_URI}/instances/${1}/ipv4" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
