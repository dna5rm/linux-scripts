## list-plans # List Plans
# /plans

function list-plans ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get a list of all VPS plans at Vultr.

The response is an array of JSON `plan` objects, with unique `id` with sub-fields in the general format of:

  <type>-<number of cores>-<memory size>-<optional modifier>

For example: `vc2-24c-96gb-sc1`

More about the sub-fields:

* `<type>`: The Vultr type code. For example, `vc2`, `vhf`, `vdc`, etc.
* `<number of cores>`: The number of cores, such as `4c` for "4 cores", `8c` for "8 cores", etc.
* `<memory size>`: Size in GB, such as `32gb`.
* `<optional modifier>`: Some plans include a modifier for internal identification purposes, such as CPU type or location surcharges.

> Note: This information about plan id format is for general education. Vultr may change the sub-field format or values at any time. You should not attempt to parse the plan ID sub-fields in your code for any specific purpose.
	Ref: /plans
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	type            query   false   false    the results by type.nn| **Type** | **Description** |n|----------|-----------------|n| all | All available types |n| vc2 | Cloud Compute |n| vdc | Dedicated Cloud |n| vhf | High Frequency Compute |n| vhp | High Performance |n| voc | All Optimized Cloud types |n| voc-g | General Purpose Optimized Cloud |n| voc-c | CPU Optimized Cloud |n| voc-m | Memory Optimized Cloud |n| voc-s | Storage Optimized Cloud |n| vcg | Cloud GPU |
	per_page        query   false   false    of items requested per page. Default is 100 and Max is 500.
	cursor          query   false   false    for paging. See [Meta and Pagination](#section/Introduction/Meta-and-Pagination).
	os              query   false   false    the results by operating system.nn|   | Type | Description |n| - | ------ | ------------- |n|   | windows | All available plans that support windows |
	
	[3mCode  Description[m
	200   OK
	
	EOF
    else
        curl --silent --location --request GET --url "${VULTR_API_URI}/plans" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${1:-{\}}"
    fi
}
