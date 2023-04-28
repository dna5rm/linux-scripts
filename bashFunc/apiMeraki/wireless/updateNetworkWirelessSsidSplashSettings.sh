## updateNetworkWirelessSsidSplashSettings # Modify the splash page settings for the given SSID
# https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-splash-settings

function updateNetworkWirelessSsidSplashSettings ()
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
	$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - Modify the splash page settings for the given SSID
	Ref: https://developer.cisco.com/meraki/api-v1/#!update-network-wireless-ssid-splash-settings
	---
	Meraki API Base URI: \${meraki_uri} (${meraki_uri:-required})
	API Authorization Key: \${auth_key} (${auth_key:-required})
	networkId: \${1} (${1:-required})
	number: \${2} (${2:-required})
	---
	splashUrl: [optional] The custom splash URL of the click-through splash page. Note that the URL can be configured without necessarily being used. In order to enable the custom URL, see 'useSplashUrl'
	useSplashUrl: [optional] Boolean indicating whether the users will be redirected to the custom splash url. A custom splash URL must be set if this is true. Note that depending on your SSID's access control settings, it may not be possible to use the custom splash URL.
	splashTimeout: Splash timeout in minutes. This will determine how often users will see the splash page.
	redirectUrl: The custom redirect URL where the users will go after the splash page.
	useRedirectUrl: The Boolean indicating whether the the user will be redirected to the custom redirect URL after the splash page. A custom redirect URL must be set if this is true.
	welcomeMessage: The welcome message for the users on the splash page.
	splashLogo: The logo used in the splash page.
	splashImage: The image used in the splash page.
	splashPrepaidFront: The prepaid front image used in the splash page.
	blockAllTrafficBeforeSignOn: How restricted allowing traffic should be. If true, all traffic types are blocked until the splash page is acknowledged. If false, all non-HTTP traffic is allowed before the splash page is acknowledged.
	controllerDisconnectionBehavior: How login attempts should be handled when the controller is unreachable. Can be either 'open', 'restricted', or 'default'.
	allowSimultaneousLogins: Whether or not to allow simultaneous logins from different devices.
	guestSponsorship: Details associated with guest sponsored splash.
	billing: Details associated with billing splash.
	sentryEnrollment: Systems Manager sentry enrollment splash settings.
	EOF
    else
        ### PLACEHOLDER cURL - FIX ME ###
        echo curl --silent --output /dev/null --write-out "%{http_code}\n" --location \
          --request PUT --url "${meraki_uri}/networks/${1}/wireless/ssids/${2}/splash/settings" \
          --header "Content-Type: application/json" \
          --header "Accept: application/json" \
          --header "X-Cisco-Meraki-API-Key: ${auth_key}" \
	  --data "${2}"
    fi
}
