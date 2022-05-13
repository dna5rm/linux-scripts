#!/bin/env -S bash
## Vultr DNS updater.
#
# crontab> SHELL=/bin/bash
# crontab> @hourly [[ -x "${HOME}/bin/vultr_dns.sh" ]] && { "${HOME}/bin/vultr_dns.sh"; }
#

bashFunc=(
    "boxText"
    "cacheExec"
    "selfGeoIP"
    "y2j"
    "apiVultr/del_domains_records"
    "apiVultr/get_domains"
    "apiVultr/get_domains_records"
    "apiVultr/post_domains_records"
)

# Load bash functions.
for func in ${bashFunc[@]}
 do [[ ! -e "${HOME}/bin/bashFunc/${func}.sh" ]] && {
     echo "$(basename "${0}"): ${func} not found!"
     exit 1
    } || { . "${HOME}/bin/bashFunc/${func}.sh"; }
done || exit 1

crc1net_auth="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.root')"
vultr_auth="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.vultr')"
vultr_uri="https://api.vultr.com/v2"

[[ "${1,,}" == *help ]] && {

boxText "$(basename "${0}") - Vultr DNS Updater"
cat <<-EOF

Usage:

    1. When ran by itself it will automaticly update AAAA with locally defined hostname.
    2. When ran with fqdn hostname as its only option it will update an A record.
    3. Providing both hostname and IP it will update an A or AAAA record.
    4. Prefixing a fqdn with a "-" the script will delete the record. (ex: -host.domain.tld)

EOF

} || {
    # Post local record (IPv6)
    if [[ -z "${1}" ]] && [[ -z "${2}" ]]; then

	    selfHost="$(hostname -a 2> /dev/null || hostname -f)"
	    selfIp="$(selfGeoIP | jq -r '.ip_addr')"
	    currentIp="$(get_domains_records "${selfHost}" | jq -r --arg selfHost "${selfHost%%.*}" '.[] | select(.name == $selfHost and .type == "AAAA") .data')"

	    [[ "${selfIp}" != "${currentIp}" ]] && {
	        post_domains_records "${selfHost}" "${selfIp}"
	    }

    # Delete record
    elif [[ "${1}" == "-"* ]]; then

	    del_domains_records "${1/-}"

    # Post local record (IPv4)
    elif [[ ! -z "${1}" ]] && [[ -z "${2}" ]]; then

	    selfHost="${1}"
	    selfIp="$(selfGeoIP true | jq -r '.ip_addr')"
	    currentIp="$(get_domains_records "${selfHost}" | jq -r --arg selfHost "${selfHost%%.*}" '.[] | select(.name == $selfHost and .type == "A") .data')"

	    [[ "${selfIp}" != "${currentIp}" ]] && {
	        post_domains_records "${selfHost}" "${selfIp}"
	    }

    # Post record
    elif [[ ! -z "${1}" ]] && [[ ! -z "${2}" ]]; then

	    post_domains_records "${1}" "${2}"

    fi
}
