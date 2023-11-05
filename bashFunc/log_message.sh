function log_message() {
    local logger_message=( ${@} )
    local logger_cmd="${logger_message[0]}"
    unset logger_message[0]

    if ! type "${logger_cmd}" >/dev/null 2>&1; then
        local func_error="${logger_cmd} executable not found or missing."
    elif [[ "${#logger_message[@]}" == "0" ]]; then
        local func_error="Missing log message."
    fi

    [[ ! -z "${func_error}" ]] && {
        echo >&2 "${FUNCNAME[0]} - ${func_error}"
        return 1
    } || {
        local msg="$(date +"%Y-%m-%d %H:%M:%S") ${logger_cmd}: ${logger_message[@]}"
        [[ ! -f "${HOME}/log/$(basename "${0%.*}").log" ]] && {
            install -m 644 -D <(echo "${msg}") "${HOME}/log/$(basename "${0%.*}").log"
        } || {
            echo "${msg}" >> "${HOME}/log/$(basename "${0%.*}").log"
        }
    }
}
