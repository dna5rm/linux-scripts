#!/bin/env -S bash
# Generating a GraphViz file that displays LLDP (Link Layer Discovery Protocol) data for a list of hosts.
## Only works against NXOS & IOS devices.

community="public"

## Bash functions to load.
bashFunc=(
    "contains_element"
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

# Main Loop
[[ -z "${@}" ]] && { echo "$(basename "${0}"): Missing list of hosts."; } || {

cat <<-EOF # Initialize the GraphViz file.
digraph G {
  margin=0.5; // either one (all) or two (hor,vert) numbers, in inches
  bgcolor="#ffffff00" // rgba in hex format
  rankdir=tb // other options would be RL, TB, BT
  compound=true // this enables logical arrow heads
  fontname="monoidregular" // should be a valid webfont

  graph [
    label     = "LLDP L1 Report (${#@})"
    labelloc  = t
  ];
  node [
    // General rules for _all_ nodes
    fontname=monoidregular // Quotes are not mandatory
    labelloc=c // vert. centred labels
    margin="0.3,0.15" // side and top margin for text in nodes
    splines=true // allows curved arrows
    shape=rect
    style=rounded
    width=2
  ];
  edge [
    dir="both"
    minlen=3
  ];

  subgraph cluster_query {
    label="Query Hosts"
    margin=19 // subgraph inherits margin from graph, bad
    style="filled,rounded,dotted"; // example of styles
    fillcolor="#00000012" // transparency stacks
    rank=same;
$(for s in ${@}; do echo "    \"${s,,}\""; done)
  }

EOF

    SysName=() # Start w/empty array.
    for host in ${@}; do

        # Get lldpLocSysName of host.
        lldpLocSysName="$(sed 's/"//g;s/\..*//' <(snmpget -Oqv -v2c -c ${community:-public} ${host} .1.0.8802.1.1.2.1.3.3.0 2> /dev/null) | tr '[:upper:]' '[:lower:]')"

        [[ ! -z "${lldpLocSysName}" ]] && {

        SysName+=( ${lldpLocSysName,,} ) # Add to array.

        # Collect lldpRemPortId that contain a ifPhysAddress
        sed 's/^\..*\.0\.//g;s/"//g;s/\.[0-9]* / /' <(snmpwalk -Oqn -v2c -c ${community:-public} ${host} .1.0.8802.1.1.2.1.4.1.1.7.0 2> /dev/null) | while read ifPhysAddress lldpRemPortId ; do

            lldpLocPortId="$(sed 's/"//g' <(snmpget -Oqv -v2c -c ${community:-public} ${host} 1.0.8802.1.1.2.1.3.7.1.3.${ifPhysAddress%% *} 2> /dev/null))"
            lldpRemSysName="$(sed 's/"//g;s/\..*//' <(snmpget -Oqv -v2c -c ${community:-public} ${host} 1.0.8802.1.1.2.1.4.1.1.9.0.${ifPhysAddress%% *}.0 2> /dev/null))"
            [[ "${lldpRemSysName}" == *"OID" ]] && {
                lldpRemSysName="$(sed 's/"//g;s/\..*//' <(snmpwalk -Oqv -v2c -c ${community:-public} ${host} 1.0.8802.1.1.2.1.4.1.1.9.0.${ifPhysAddress%% *} 2> /dev/null))"
            }

            contains_element "${lldpRemSysName,,}" "${SysName}" && {
                echo "  \"${lldpLocSysName,,}\" -> \"${lldpRemSysName,,}\" [dir=\"both\", label=\"${lldpLocPortId}\\n${lldpRemPortId}\"]"
            }

        done
        }

    done

echo "}" # Done.

}
