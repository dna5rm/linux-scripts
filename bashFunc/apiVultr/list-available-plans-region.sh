## list-available-plans-region # List available plans in region
# /regions/{region-id}/availability

function list-available-plans-region ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Get a list of the available plans in Region `region-id`. Not all plans are available in all regions.
	Ref: /regions/{region-id}/availability
	---
	API Base URI: \${VULTR_API_URI} (${VULTR_API_URI:-required})
	Authorization Key: \${VULTR_API_KEY} (${VULTR_API_KEY:-required})
	
	[3mParamater       Input   Req.    Type     Description[m
	type            query   false   false    the results by type.nn| **Type** | **Description** |n|----------|-----------------|n| all | All available types |n| vc2 | Cloud Compute |n| vdc | Dedicated Cloud |n| vhf | High Frequency Compute |n| vhp | High Performance |n| voc | All Optimized Cloud types |n| voc-g | General Purpose Optimized Cloud |n| voc-c | CPU Optimized Cloud |n| voc-m | Memory Optimized Cloud |n| voc-s | Storage Optimized Cloud |n| vbm | Bare Metal |n| vcg | Cloud GPU |n
	
	[3mCode  Description[m
	200   OK
	
	EOF
    else
        curl --silent --location --request GET --url "${VULTR_API_URI}/regions/${1}/availability" \
          --header "Authorization: Bearer ${VULTR_API_KEY}" \
          --header "Content-Type: application/json" \
          --data "${2:-{\}}"
    fi
}
