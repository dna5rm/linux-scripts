## getme # A simple method for testing your bot's authentication token.
# https://core.telegram.org/bots/api#getme

function getMe () {
    if ! type curl > /dev/null 2>&1; then
        local func_error="curl executable not found."
    elif ! type jq > /dev/null 2>&1; then
        local func_error="jq executable not found."
    elif [[ -z "${TELEGRAM_TOKEN}" ]]; then
        local func_error="Missing \${TELEGRAM_TOKEN}"
    fi

    [[ ! -z "${func_error}" ]] && {
        echo "${FUNCNAME[0]} - ${func_error}" 1>&2
        return 1
    } || {
        local response=$(curl --silent --insecure --location --write-out "%{http_code}" --request POST --url "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getMe" --header "Content-Type: application/json")
        local http_code="${response##*[!0-9]}"

        case "${http_code}" in
            200)
                jq -c 'if .ok == true then .result else empty end' <(sed 's/[0-9]*$//' <<< "${response}")
            ;;
            *)
                local response=`jq -c '.description' <(sed 's/[0-9]*$//' <<< "${response}")`
                echo "[${FUNCNAME[0]}:${http_code}] ${response}" 1>&2
                return 1
            ;;
        esac
    }
}
