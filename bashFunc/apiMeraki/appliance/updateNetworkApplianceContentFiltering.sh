## updateNetworkApplianceContentFiltering # Update the content filtering settings for an MX network
# https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-content-filtering

function updateNetworkApplianceContentFiltering ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${2}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the content filtering settings for an MX network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-appliance-content-filtering
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	---
	allowedUrlPatterns: A list of URL patterns that are allowed
	blockedUrlPatterns: A list of URL patterns that are blocked
	blockedUrlCategories: A list of URL categories to block
	urlCategoryListSize: URL category list size which is either 'topSites' or 'fullList'
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/appliance/contentFiltering" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
