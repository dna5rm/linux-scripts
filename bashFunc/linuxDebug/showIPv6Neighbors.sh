## showIPv6Neighbors.sh # Show IPv6 Neighbors

if sudo -v &> /dev/null; then
function showIPv6Neighbors ()
{

    # Verify function requirements.
    for req in curl tput; do
        type ${req} >/dev/null 2>&1 || {
            echo >&2 "$(basename "${0}" 2> /dev/null):${FUNCNAME[0]} - ${req} is not installed. Aborting."
            exit 1
        }
    done

    # Fetch oui.txt for HWaddress lookup.
    [[ ! -f "/usr/local/etc/oui.txt" ]] && {
        sudo install -m 644 -D <(curl --silent --insecure --output - https://standards-oui.ieee.org/oui/oui.txt) "/usr/local/etc/oui.txt"
    }


    printf "%-40s %-10s %-18s %-6s %-26s\n" "Address" "State" "HWaddress" "Iface" "Manufacturer" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"
    ip -6 neighbor | awk '{if($(NF-1) == "router") { rtr="y"; }; if($4 == "lladdr") { print $1,$3,$5,$NF,rtr; rtr="" }}' |\
     while read Address Iface HWaddress State rtr; do

        OUI="$(echo ${HWaddress:0:8} | sed 's/://g;s/.*/\U&/')"
        HWvendor="$(awk -F'\t' 'BEGIN{IGNORECASE = 1}/^'''${OUI}'''/{gsub(/\r/, ""); print $NF}' "/usr/local/etc/oui.txt")"

        [[ "${rtr,,}" == "y" ]] && {
            printf "%-40s %-10s %-18s %-6s %s\n" "${Address}" "${State}" "${HWaddress}" "${Iface}" "${HWvendor:--}" |\
            sed "1 s,.*,$(tput smul)&$(tput sgr0),"
        } || {
            printf "%-40s %-10s %-18s %-6s %s\n" "${Address}" "${State}" "${HWaddress}" "${Iface}" "${HWvendor:--}"
        }
    done

}
fi
