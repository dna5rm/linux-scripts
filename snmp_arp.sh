#!/usr/bin/env bash
## Req: jq, curl, pip:snmpclitools
## SNMP Ref: https://oidref.com/1.3.6.1.2.1.1.1.0

OUIDB=( "http://standards-oui.ieee.org/oui/oui.csv" "${HOME}/.cache/oui.json" )

### GETOPT ##
ARGS=$(getopt -o 'c:' --long 'community:' -- "$@") || exit
eval "set -- $ARGS"

for i in ${ARGS}; do
    case ${i} in
        (-c|--community) snmp_community="${2:-public}"; shift;;
        (--) shift 1; snmp_hosts="${@}";;
    esac
done

### MAIN ###
if [ "${snmp_hosts}" != "" ]; then

    # Build OUI db for refrence.
    if [[ ! -s "${OUIDB[1]}" ]] || [[ ! -z "$(find "${OUIDB[1]}" -mtime +365)" ]]; then
        wget -O- "${OUIDB[0]}" 2> /dev/null | awk 'BEGIN {
            FPAT = "([^,]+)|(\"[^\"]+\")"
            count=0
            printf("[\n")
        } /^[Registry]|^[MA]/ {
            gsub(/[\r]/, "\n")  # Strip CTRL+M
            gsub(/[\t]/, " ")   # Strip TAB
            gsub(/[\\]/, " ")   # Strip \
            if( $1 != "Registry") {
                gsub(/["]/, "", $3)
                gsub(/["]/, "", $4)
                gsub(/[ |\n]*$/, "", $4)
                if( count != 0) {
                    printf(",\n")
                }
                printf("  { \"Registry\": \"%s\", \"Assignment\": \"%s\", \"Name\": \"%s\", \"Address\": \"%s\" }", $1, $2, $3, $4)
                ++count
            }
        } END {
            printf("\n]")
        }' | jq '.' > "${OUIDB[1]}"
    fi

    for snmp_host in ${snmp_hosts}; do
        if [ "${snmp_host}" != "--" ]; then
            printf "%.0s#" {1..80}
            printf "\n%*s\n" $(((${#snmp_host}+80)/2)) " ${snmp_host} "
            printf "%.0s#" {1..80}
            printf "\n"

            # Get SysDescr.0
            snmpget.py -v 2c -c ${snmp_community:-public} -O qQUv ${snmp_host} .1.3.6.1.2.1.1.1.0

            # Get ifOperStatus = up
            ifOperUp=( "$(snmpwalk.py -v 2c -c ${snmp_community:-public} -O qsn ${snmp_host} .1.3.6.1.2.1.2.2.1.8 | awk -F'.' '{split($NF,i," "); if(i[2] == 1){printf i[1]" "}}')" )

            # Walk ipNetToMediaPhysAddress
            for i in ${ifOperUp}; do
                ifName="$(snmpget.py -v 2c -c ${snmp_community:-public} -O qv ${snmp_host} .1.3.6.1.2.1.31.1.1.1.1.${i})"
                ifAlias="$(snmpget.py -v 2c -c ${snmp_community:-public} -O qv ${snmp_host} .1.3.6.1.2.1.31.1.1.1.18.${i})"

                # Only interested in L3 interfaces
                case ${ifName} in
                    "Gi"*|"Vl"*) printf "%.0s#" {1..80} && printf "\r### ${ifName} $([ "${ifAlias}" != "" ] && {
                        echo "## ${ifAlias} "
                    })###\r\n"
                    snmpwalk.py -v 2c -c ${snmp_community:-public} -O nq ${snmp_host} .1.3.6.1.2.1.4.22.1.2.${i} | awk '{ gsub(/^0x/, "", $NF)
                            split($1, a, ".")
                            print(a[length(a)-3]"."a[length(a)-2]"."a[length(a)-1]"."a[length(a)],$NF)
                          }' | while read ip mac; do
                            vendor="$(jq -r --arg a "${mac:0:6}" '.[] | select(.Assignment == $a) | .Name' "${OUIDB[1]}" 2> /dev/null)"
                            printf "%-10s %-18s %-18s %s\n" "${ifName}" "${ip}" "$(printf ${mac} | awk '{gsub(/....\B/,"&.")}1')" "${vendor}"
                        done ;;
                esac
            done
        fi
    done

### HELP ###
else
    echo "`basename ${0}` -c <community> [host1 host2 ...]"
fi
