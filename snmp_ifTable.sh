#!/bin/env -S bash

#community="private"
#debug=true

[[ -z "${@}" ]] && { echo "$(basename "${0}"): Missing list of hosts."; } || {

    # Reference record for ifEntry (OID 1.3.6.1.2.1.2.2.1.1)
    ifTable=( Index ifDescr ifType ifMtu ifSpeed ifPhysAddress ifAdminStatus ifOperStatus ifLastChange ifInOctets ifInUcastPkts ifInNUcastPkts ifInDiscards ifInErrors ifInUnknownProtos ifOutOctets ifOutUcastPkts ifOutNUcastPkts ifOutDiscards ifOutErrors ifOutQLen ifSpecific ifStateChangeTrapEnable ifClearStats ifClearStatsTime ifErrorRateTrapEnable ifErrorRateInterval ifErrorInLowThreshold ifErrorInHighThreshold ifErrorOutLowThreshold ifErrorOutHighThreshold ifErrType )
    # Reference record for ifXTable (OID 1.3.6.1.2.1.31.1.1.1)
    ifXTable=( Index ifName ifInMulticastPkts ifInBroadcastPkts ifOutMulticastPkts ifOutBroadcastPkts ifHCInOctets ifHCInUcastPkts ifHCInMulticastPkts ifHCInBroadcastPkts ifHCOutOctets ifHCOutUcastPkts ifHCOutMulticastPkts ifHCOutBroadcastPkts ifLinkUpDownTrapEnable ifHighSpeed ifPromiscuousMode ifConnectorPresent ifAlias ifCounterDiscontinuityTime )

    for host in ${@}; do

        # Get sysName of host.
        sysName="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} .1.3.6.1.2.1.1.5.0 2> /dev/null) | tr '[:upper:]' '[:lower:]')"

        [[ ! -z "${sysName}" ]] && {
        # Collect ifTable devices that contain a ifPhysAddress
        sed 's/^\..*\.6\.//g;s/"//g' <(snmpwalk -Oqn -v2c -c ${community:-public} ${host} .1.3.6.1.2.1.2.2.1.6 2> /dev/null) | while read ifPhysAddress; do

            # Only display devices that have a ifPhysAddress
            set -- ${ifPhysAddress} && [[ ${#} -gt 1 ]] && {
                if [[ ! -z "${debug}" ]]; then
                    echo "$(printf "#%.0s" $(seq 1 63))"
                    echo "1.3.6.1.2.1.2.2.1.1.${ifPhysAddress%% *}"
                    echo "$(printf "#%.0s" $(seq 1 63))"
                    for i in $(seq -s' ' $((${#ifTable[@]}-1))); do
                        printf "%-35s %s\n" "${ifTable[i]} ($((${i}+1)))" "$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} 1.3.6.1.2.1.2.2.1.$((${i}+1)).${ifPhysAddress%% *}))"
                    done
                    echo "$(printf "=%.0s" $(seq 1 63))"
                    echo "1.3.6.1.2.1.31.1.1.1.${ifPhysAddress%% *}"
                    echo "$(printf "=%.0s" $(seq 1 63))"
                    for i in $(seq -s' ' $((${#ifXTable[@]}-1))); do
                        printf "%-35s %s\n" "${ifXTable[i]} (${i})" "$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} 1.3.6.1.2.1.31.1.1.1.${i}.${ifPhysAddress%% *}))"
                    done
                else
                    ifDescr="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} 1.3.6.1.2.1.2.2.1.2.${ifPhysAddress%% *} 2> /dev/null))"
                    ifMtu="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} 1.3.6.1.2.1.2.2.1.4.${ifPhysAddress%% *} 2> /dev/null))"
                    ifSpeed="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} 1.3.6.1.2.1.2.2.1.5.${ifPhysAddress%% *} 2> /dev/null))"
                    ifAlias="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} 1.3.6.1.2.1.31.1.1.1.18.${ifPhysAddress%% *} 2> /dev/null))"
                    printf "%-16s %-6d %-28s %-5s %-12s %-18s %s\n" "${sysName%%.*}" "${ifPhysAddress%% *}" "${ifDescr}" "${ifMtu}" "${ifSpeed}" "$(sed 's/ /:/g;s/\(.*\)/\U\1/' <<<${ifPhysAddress#* })" "${ifAlias}"
                fi
            }
        done
        }

    done
}
