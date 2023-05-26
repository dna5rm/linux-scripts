## create-instance # Create Instance
# /instances

function create-instance ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Create a new VPS Instance in a `region` with the desired `plan`. Choose one of the following to deploy the instance:

* `os_id`
* `iso_id`
* `snapshot_id`
* `app_id`
* `image_id`

Supply other attributes as desired.
	Ref: /instances
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})

	[3mCode  Description[m
	202   Created
	400   Bad Request
	401   Unauthorized
	403   Forbidden
	404   Not Found
	
	EOF
    else
        curl --silent --location --request POST --url "${VULTR_API_URI}/instances" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
