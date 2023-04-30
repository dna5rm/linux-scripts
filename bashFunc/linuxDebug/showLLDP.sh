## showLLDP # Show the LLDP information

if sudo -v &> /dev/null; then
function showLLDP ()
{

    # Verify function requirements.
    for req in "/usr/sbin/lldpd" tput xq; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo -en >&2 "[${ERR}] $(basename "$(test "${0}" == "-bash" && echo "${FUNCNAME[0]}" || echo "${0}")" 2> /dev/null)"
            echo " - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # Set CMD - neighbors detail
    if [[ "${1,,}" == "d"* ]]; then
        CMD="lldpcli show neighbors detail"
    # Set CMD - chassis details
    elif [[ "${1,,}" == "c"* ]]; then
        CMD="lldpcli show chassis details"
    # Set CMD - interfaces summary
    elif [[ "${1,,}" == "i"* ]]; then
        CMD="lldpcli show interfaces summary"
    # Set CMD - statistics summary
    elif [[ "${1,,}" == "s"* ]]; then
        CMD="lldpcli show statistics summary"
    # Set CMD - neighbors summary
    else
        CMD="lldpcli show neighbors summary"
    fi

    # Execute CMD
    echo "$(basename "$(test "${0}" == "-bash" && echo "${FUNCNAME[0]}" || echo "${0}")" 2> /dev/null): ${CMD}" | sed "1 s,.*,$(tput smso)&$(tput sgr0),"
    (sudo ${CMD})

}
fi
