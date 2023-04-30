## showSys # Show system information.

function showSys ()
{

    # Verify function requirements.
    for req in journalctl tput xq; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo -en >&2 "[${ERR}] $(basename "$(test "${0}" == "-bash" && echo "${FUNCNAME[0]}" || echo "${0}")" 2> /dev/null)"
            echo " - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # systemd journal summary
    if [[ "${1,,}" = "s"* ]]; then
        journalctl -o json | jq -r 'if .SYSLOG_IDENTIFIER | contains("ansible") | not then .SYSLOG_IDENTIFIER else empty end' | sort | uniq -c | sort -nr | awk 'BEGIN{printf("%6s %-25s\n", "Hits", "Service")}//{printf("%6s %-25s\n", $1, $2)}'
    # uname placeholder
    else
        uname -a
    fi | sed "1 s,.*,$(tput smso)&$(tput sgr0),"

}
