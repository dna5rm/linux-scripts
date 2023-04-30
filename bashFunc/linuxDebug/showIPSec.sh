## showIPSec # Show the IPSec information

if sudo -v &> /dev/null; then
function showIPSec ()
{

    # Verify function requirements.
    for req in "/usr/sbin/swanctl" "/usr/sbin/ipsec" tput xq; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo -en >&2 "[${ERR}] $(basename "$(test "${0}" == "-bash" && echo "${FUNCNAME[0]}" || echo "${0}")" 2> /dev/null)"
            echo " - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # Set CMD - IPsec details
    if [[ "${1,,}" == "det"* ]]; then
        CMD="ipsec statusall"
    # Set CMD - VTI details
    elif [[ "${1,,}" == "vti" ]]; then
        CMD="ip -s xfrm state"
    # Set CMD - IKE details
    elif [[ "${1,,}" == "ike" ]]; then
        CMD="swanctl --list-sas"
    # Set CMD - IPsec Logs
    elif [[ "${1,,}" == "log" ]]; then
        CMD="swanctl --log"
    # Set CMD - IPsec status
    else
        CMD="ipsec status"
    fi

    # Execute CMD
    echo "$(basename "$(test "${0}" == "-bash" && echo "${FUNCNAME[0]}" || echo "${0}")" 2> /dev/null): ${CMD}" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"
    (sudo ${CMD})

}
fi
