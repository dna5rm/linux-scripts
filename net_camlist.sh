#!/bin/env -S bash
# Generate PingInfoView address list for datacenter migration.
# Ref: https://www.nirsoft.net/utils/multiple_ping_tool.html

community="public"

#-------------------------#
# list of target switches #
#-------------------------#

switches=(
    switch01a
    switch01b
    switch02a
    switch02b
)

l3cores=(
    core01
    core02
)

#--------------------------#
# test script requirements #
#--------------------------#

for req in python3 jq xq; do
    type ${req} >/dev/null 2>&1 || {
        echo >&2 "$(basename "${0}"): I require ${req} but it's not installed. Aborting."
        exit 1
    }
done

#------------------#
# download oui.txt #
#------------------#

[[ ! -f "$(dirname ${0})/oui.txt" ]] && {
    curl -o "$(dirname ${0})/oui.txt" "https://standards-oui.ieee.org/oui/oui.txt"
}

#----------------------------#
# show arp - cisco l3 (snmp) #
#----------------------------#

for l3 in ${l3cores[@]}; do
    if [[ ! -f "$(dirname ${0})/l3core-arp.json" ]]; then
        echo "[${l3}] Collecting ARP..."

        # start with empty json
        echo "[]" > "$(dirname ${0})/l3core-arp.json"

        #---------------------------#
        # mib::1.3.6.1.2.1.4.22.1.2 #
        #---------------------------#

        snmpwalk -v2c -OSXq -c ${community} ${l3} 1.3.6.1.2.1.4.22.1.2 | awk -F'[' '{gsub(/]/, ""); print $NF}' | while read IP B; do
            MAC="$(echo ${B} | awk '{split(tolower($1),p,":");printf("%02x%02x.%02x%02x.%02x%02x\n",strtonum("0x"p[1]),strtonum("0x"p[2]),strtonum("0x"p[3]),strtonum("0x"p[4]),strtonum("0x"p[5]),strtonum("0x"p[6]))}')"
            OUI="$(echo ${MAC} | awk '{gsub(/\./, ""); print substr(toupper($0),1,6)}')"

            [[ -f "$(dirname ${0})/oui.txt" ]] && {
                 ORGANIZATION="$(grep "${OUI}" "$(dirname ${0})/oui.txt" | awk '{gsub(/\r/, ""); print substr($0,23,40)}')"
            }

            #------------------------#
            # sponge entry into json #
            #------------------------#

            echo -en "\r${MAC}             "
            jq -c --arg mac "${MAC}" --arg ip "${IP}" --arg org "${ORGANIZATION:-}" '. += [{"mac-addr": $mac, "ip-addr": $ip, "org-name": $org}]' "$(dirname ${0})/l3core-arp.json" > "$(dirname ${0})/_tmp"
            jq '.' "$(dirname ${0})/_tmp" > "$(dirname ${0})/l3core-arp.json"
        done && rm "$(dirname ${0})/_tmp"
        echo
    fi
done

#-------------------------------#
# show mac address-table - nxos #
#-------------------------------#

for switch in ${switches[@]}; do

    #-------------------------------------#
    # update cam xml if older than 1 hour #
    #-------------------------------------#

    # use rancid/clogin to login and show cam table
    if [[ ! -f "$(find "$(dirname ${0})/${switch}.xml" -mmin +60 -print 2> /dev/null)" ]]; then
        clogin -c "show mac address-table | xmlout" "${switch}" | sed -n '/rpc-reply/,/rpc-reply/p' | tee "$(dirname ${0})/${switch}.xml"
    else
        cat "$(dirname ${0})/${switch}.xml"
    fi | python3 -c 'import sys,json,xmltodict; print(json.dumps(xmltodict.parse(sys.stdin.read()),indent=2))' |\
         jq -r '[.["nf:rpc-reply"]["nf:data"]["show"]["mac"]["address-table"]["__readonly__"]["TABLE_mac_address"]["ROW_mac_address"][] | select(.disp_port | startswith("Eth"))] | (.[] | [.disp_vlan, .disp_mac_addr, .disp_port]) | @tsv' | while read vlan mac port; do

             #---------------------------------#
             # query arp table for mac as list #
             #---------------------------------#

             addr=( $(jq -r --arg mac ${mac} '.[] | select(.["mac-addr"]==$mac) | select(.["ip-addr"] | test("^[0-9]")) | .["ip-addr"]' "$(dirname ${0})/l3core-arp.json") )

             # addr is defined
             [[ ! -z "${addr}" ]] && {

                 # ieee org name
                 org="$(jq -r --arg mac ${mac} '.[] | select(.["mac-addr"]==$mac) | .["org-name"]' "$(dirname ${0})/l3core-arp.json" | head -n1)"

                 #-------------------#
                 # iterate addr list #
                 #-------------------#

                 for a in ${addr[@]}; do

                     # dns hostname
                     domain="$(awk 'END{if(tolower($1) != "host") { split($NF,host, "."); print host[1] }}' <(host ${a}))"

                     #----------------------------------#
                     # output: x.x.x.x icmp_target_name #
                     #----------------------------------#

                     [[ ! -z "${domain}" ]] && {
                         printf "%-18s %s\n" "${a}" "$(printf "%-26s %s" "${switch}:${port}" "${domain,,}" | sed 's/[ ]/_/g;s/[_]*$//')"
                     } || {
                         printf "%-18s %s\n" "${a}" "$(printf "%-26s %s" "${switch}:${port}" "${org^^}" | sed 's/[ |,|\.]/_/g;s/[_]*$//')"
                     }

                 done
             }
         done | awk '{print $1,$2}'
done
