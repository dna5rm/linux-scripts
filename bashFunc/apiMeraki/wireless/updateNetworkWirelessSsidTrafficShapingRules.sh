## updateNetworkWirelessSsidTrafficShapingRules # Update the traffic shaping settings for an SSID on an MR network
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-traffic-shaping-rules

function updateNetworkWirelessSsidTrafficShapingRules ()
{
    # Verify function requirements
    for req in curl; do
        type  >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    if [[ -z "${meraki_uri}" ]] || [[ -z "${auth_key}" ]] || [[ -z "${3}" ]]; then
	cat <<-EOF
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Update the traffic shaping settings for an SSID on an MR network
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-traffic-shaping-rules
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	---
	trafficShapingEnabled: Whether traffic shaping rules are applied to clients on your SSID.
	defaultRulesEnabled: Whether default traffic shaping rules are enabled (true) or disabled (false). There are 4 default rules, which can be seen on your network's traffic shaping page. Note that default rules count against the rule limit of 8.
	rules:     An array of traffic shaping rules. Rules are applied in the order that
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/ssids/${2}/trafficShaping/rules" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
