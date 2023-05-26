#!/bin/env -S bash
## Vultr DNS updater.

### Verify requirements ###
for req in curl jq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done

### Functions ###

# List of functions.
bashFunc=(
    "cacheExec"
    "validate"
    "y2j"
    "apiVultr/list-dns-domains"
    "apiVultr/list-dns-domain-records"
    "apiVultr/create-dns-domain-record"
    "apiVultr/delete-dns-domain-record"
    "apiVultr/update-dns-domain-record"
)

## Load bash functions.
for func in ${bashFunc[@]}; do
    [[ ! -e "$(dirname "${0}")/bashFunc/${func}.sh" ]] && {
        echo "$(basename "${0}"): ${func} not found!"
        exit 1
    } || {
        . "$(dirname "${0}")/bashFunc/${func}.sh"
    }
done || exit 1

### Variables ###
VULTR_API_KEY="$(y2j < "${HOME}/.loginrc.yaml" | jq -r '.vultr')"
VULTR_API_URI="https://api.vultr.com/v2"

fqdn="${1,,}"
data="${2,,}"

[[ -z "${data}" ]] && {

    cat <<-EOF | sed "1 s,.*,$(tput smso)&$(tput sgr0),"
	$(basename "${0}") - Vultr DNS Updater

	Syntax: $(basename "${0}") {fqdn} {address}

	Note:
	  - Prefixing a {fqdn} with a "-" will delete the record. (ex: -host.domain.tld)

	EOF

} || {

    # Check if domain is managed.
    [[ `cacheExec list-dns-domains | jq -r --arg domain "${fqdn#*.}" '.domains[] | select(.domain == $domain) | any'` == "true" ]] && {

        name=`sed 's/^-//' <<<${fqdn%%.*}`

        # Data is IPv4?
        if validate::ipv4 "${data}"; then
            record=`list-dns-domain-records "${fqdn#*.}" | jq -c --arg record "${name}" --arg type "A" '.records[] | select(.name == $record and .type == $type)'`
            record_update=`jq -c --arg record "${name}" '. + {"name": $record, "type": "A"}' <<<${record:-{\}}`
        # Data is IPV6?
        elif validate::ipv6 "${data}"; then
            record=`list-dns-domain-records "${fqdn#*.}" | jq -c --arg record "${name}" --arg type "AAAA" '.records[] | select(.name == $record and .type == $type)'`
            record_update=`jq -c --arg record "${name}" '. + {"name": $record, "type": "AAAA"}' <<<${record:-{\}}`
        fi

        record_update=`jq -c --arg data "${data}" '.data = $data' <<<${record_update:-{\}}`
        record_update=`jq -c '.priority = -1' <<<${record_update:-{\}}`
        record_update=`jq -c '.ttl = 300' <<<${record_update:-{\}}`

        # Diff between records.
        #diff -y <(jq -S '.' <<<${record:-{\}}) <(jq -S '.' <<<${record_update:-{\}})

        # Unknown record type.
        if [[ -z `jq -r '.type //empty' <<<${record_update}` ]]; then
            echo >&2 "$(basename "${0}") - Unknown DNS record type."
        # Delete record.
        elif [[ "${fqdn:0:1}" == "-" ]] && [[ ! -z `jq -r '.id //empty' <<<${record}` ]]; then
            delete-dns-domain-record "${fqdn#*.}" "$(jq -r '.id' <<<${record})"
        # Create new record.
        elif [[ -z `jq -r '.id //empty' <<<${record_update}` ]]; then
            create-dns-domain-record "${fqdn#*.}" "${record_update}" | jq -S '.record'
        # Update existing record.
        elif [[ `jq -Sc '.' <<<${record:-{\}}` != `jq -Sc '.' <<<${record_update}` ]]; then
            update-dns-domain-record "${fqdn#*.}" "$(jq -r '.id' <<<${record})" "$(jq -c 'del(.id)' <<<${record_update})"
        fi
    }
}
