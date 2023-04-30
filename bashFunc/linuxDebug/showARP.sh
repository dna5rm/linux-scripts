## showARP # Show the ARP cache

if sudo -v &> /dev/null; then
function showARP ()
{

    # Verify function requirements.
    for req in curl tput; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo -en >&2 "[${ERR}] $(basename "$(test "${0}" == "-bash" && echo "${FUNCNAME[0]}" || echo "${0}")" 2> /dev/null)"
            echo " - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # Fetch oui.txt for HWaddress lookup.
    [[ ! -f "/usr/local/etc/oui.txt" ]] && {
        sudo install -m 644 -D <(curl --silent --insecure --output - https://standards-oui.ieee.org/oui/oui.txt) "/usr/local/etc/oui.txt"
    }

    # Format arp + HWvendor
    printf "%-15s %-6s %-18s %-6s %-34s\n" "Address" "HWtype" "HWaddress" "Iface" "Manufacturer" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"
    sudo arp -a | awk '/ether/{gsub(/[)|(|\]|\[]/, ""); print $(NF-5), $(NF-2), toupper($(NF-3)), $NF}' | while read Address HWtype HWaddress Iface; do
        OUI="$(echo ${HWaddress:0:8} | awk '{gsub(":", "-", $0); print toupper($0)}')"
        HWvendor="$(awk '/^'''${OUI}'''/ {print substr($0, index($0,$3))}' "/usr/local/etc/oui.txt")"

        printf "%-15s %-6s %-18s %-6s %s\n" "${Address}" "${HWtype}" "${HWaddress}" "${Iface}" "${HWvendor}"
    done
}
fi
