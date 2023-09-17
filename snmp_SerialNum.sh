#!/bin/env -S bash

#community="private"
#debug=true

[[ -z "${@}" ]] && { echo "$(basename "${0}"): Missing list of hosts."; } || {

    # entPhysical OID reference list.
    entPhysical=( Index Descr VendorType ContainedIn Class ParentRelPos Name HardwareRev FirmwareRev SoftwareRev SerialNum MfgName ModelName Alias AssetID IsFRU MfgDate Uris UUID )

    for host in ${@}; do

        # Get sysName of host.
        sysName="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} .1.3.6.1.2.1.1.5.0 2> /dev/null) | tr '[:upper:]' '[:lower:]')"

        [[ ! -z "${sysName}" ]] && {
        # Collect entPhysical devices that contain a SerialNum
        sed 's/^\..*\.11\.//g;s/"//g' <(snmpwalk -Oqn -v2c -c ${community:-public} ${host} .1.3.6.1.2.1.47.1.1.1.1.11 2> /dev/null) | while read entPhysicalSerialNum; do

            # Only display devices that have a SerialNum
            set -- ${entPhysicalSerialNum} && [[ ${#} -gt 1 ]] && {
                if [[ ! -z "${debug}" ]]; then
                    echo "$(printf "=%.0s" $(seq 1 63))"
                    for i in {1..18}; do
                        printf "%-18s %s\n" "${entPhysical[i]} ($((${i}+1)))" "$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} .1.3.6.1.2.1.47.1.1.1.1.$((${i}+1)).${entPhysicalSerialNum%% *}))"
                    done
                elif [[ "${entPhysicalSerialNum}" != *"No Such Object"* ]]; then
                    entPhysicalDescr="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} .1.3.6.1.2.1.47.1.1.1.1.2.${entPhysicalSerialNum%% *} 2> /dev/null))"
                    entPhysicalModelName="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} .1.3.6.1.2.1.47.1.1.1.1.13.${entPhysicalSerialNum%% *} 2> /dev/null))"
                    printf "%-16s %-6d %-16s %-20s %s\n" "${sysName%%.*}" "${entPhysicalSerialNum%% *}" "${entPhysicalSerialNum##* }" "${entPhysicalModelName}" "${entPhysicalDescr}"
                else
                    printf "%-16s %-6d\n" "${sysName%%.*}" "0"
                fi
            }
        done
        }

    done
}
