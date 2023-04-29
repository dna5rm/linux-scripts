# Meraki Dashboard API cURL Library

The Meraki Dashboard API cURL library provides all current Meraki [dashboard API](https://developer.cisco.com/meraki/api-v1/) calls to interface with the Cisco Meraki cloud-managed platform.
The library was directly scraped from the [Meraki Dashboard API Python Library](https://github.com/meraki/dashboard-api-python).

## Notice

For safetey reasons, all functions that use methods other than GET are purposely crippled via an "echo | curl" within the script.
If an API call is needed that uses a PUT/POST/DELETE, the function should be manually reviewed and uncrippled.

# Example Usage

```bash
#!/bin/env -S bash

## Bash functions to load.
bashFunc=(
    "apiMeraki/getOrganizations"
)

## Load Bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

## Set variables.
meraki_uri="https://api.meraki.com/api/v1"
auth_key="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## Main Script.
getOrganizations | jq '.'
```
