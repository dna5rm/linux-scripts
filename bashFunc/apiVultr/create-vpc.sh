## create-vpc # Create a VPC
# /vpcs

function create-vpc ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create a new VPC in a `region`. VPCs should use [RFC1918 private address space](https://tools.ietf.org/html/rfc1918):

    10.0.0.0    - 10.255.255.255  (10/8 prefix)
    172.16.0.0  - 172.31.255.255  (172.16/12 prefix)
    192.168.0.0 - 192.168.255.255 (192.168/16 prefix)
	Ref: /vpcs
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	201   Created
	400   Bad Request
	401   Unauthorized
	404   Not Found
	
	EOF
    else
        curl --silent --location --request POST --url "${VULTR_API_URI}/vpcs" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
