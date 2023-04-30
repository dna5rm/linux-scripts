## showNAT # Show NAT Table

if sudo -v &> /dev/null; then
function showNAT ()
{

    # Verify function requirements.
    for req in conntrack tput xq; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    # Create tempoary file containing NAT translations.
    if tmpFile="$(mktemp)"; then
        trap "{ if [ -e "${tmpFile}*" ]; then rm -rf "${tmpFile}*"; fi }" SIGINT SIGTERM ERR EXIT
    else
        echo "Failure, exit status: ${?}"
        exit ${?}
    fi && xq -r '.conntrack.flow[].meta | "\(.[2].id) \(.[0].layer4."@protoname") \(.[0].layer3.src) \(.[0].layer3.dst +":"+ .[0].layer4.dport) \(.[2].use)"' <(sudo conntrack -L -n --output xml 2> /dev/null) > "${tmpFile}"

    # Parse NAT translations

    ## Destination..
    if [[ "${1}" == "dst" ]]; then
        type mmdblookup >/dev/null 2>&1 && { MMDB=True; }
        awk '/^[0-9]/{print $4}' "${tmpFile}" | sort | uniq -c | sort -nr | while read line; do

            SERVICE="$(awk '/[\t| ]'''${line##*:}'''\//{print $1; exit}' "/etc/services")"
            DEST="$(awk '{print $NF}' <<<"${line%%:*}")"

            # MMDB country lookup of destination.
            if [[ -f "/opt/GeoLite2-Country.mmdb" ]] && [[ ! -z "${MMDB}" ]]; then
                COUNTRY="$(mmdblookup --file "/opt/GeoLite2-Country.mmdb" --ip "${DEST}" country iso_code 2> /dev/null | awk '/utf8/{gsub(/"/, ""); print $1}')"
            fi

            echo "${line}" "${COUNTRY:--}" "${SERVICE:--}"

        done | awk 'BEGIN{printf("%6s %-23s %-8s %-15s\n", "Hits", "Destination", "Country", "Service")}//{printf("%6s %-23s %-8s %-15s\n", $1, $2, $3, $4)}'

    ## Source..
    elif [[ "${1}" == "src" ]]; then
        awk '/^[0-9]/{print $3}' "${tmpFile}" | sort | uniq -c | sort -nr |\
        awk 'BEGIN{printf("%6s %-18s\n", "Hits", "Source")}//{printf("%6s %-18s\n", $1, $2)}'

    ## Raw Table..
    else
        awk 'BEGIN{printf("%-12s %-6s %-18s %-23s %s\n", "ID", "Proto", "Source", "Destination", "Use" )}//{printf("%-12s %-6s %-18s %-23s %s\n", $1, $2, $3, $4, $5)}' "${tmpFile}"

    fi | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

}
fi
