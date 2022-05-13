#!/bin/env -S bash
## Ansible Managed: GeoIP aclexec script for Linux TCP wrappers.
#
# /etc/hosts.allow << ALL: ALL: aclexec /opt/geowrapper.sh %a
# /etc/hosts.deny  << ALL: PARANOID
#

# Enable for debuging
# set -x

# Space-separated country codes to permit
permit="US"

# MaxMind DB
mmdb="/opt/GeoLite2-Country.mmdb"

# Verify requirements
for req in mmdblookup; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1 # return false to deny
    }
done

# geiplookup addr
[[ -z "${1}" ]] && {
    echo "$(basename "${0}"): missing address \${1}"
    exit 1 # return false to deny
} || {

    # Parse pseudo-JSON output
    src="$(mmdblookup --file "${mmdb}" --ip "${1}" country iso_code | awk '/utf8/{gsub(/"/, ""); print $1}')"

    # permit or deny addr
    [[ ${src^^} = "IP Address not found" || ${permit^^} =~ ${src^^} ]] && {
        exit 0 # return true to permit
    } || {
        logger "$(basename "${0}"): deny from ${1} (${src^^})"
        exit 1 # return false to deny
    }
}
