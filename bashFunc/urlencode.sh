# urlencode and urldecode bash functions.
# Ref: https://stackoverflow.com/a/29565580/370746
# Ref: https://stackoverflow.com/a/35512655/370746

function urlencode()
{
    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Verify function requirements
    for req in python; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo >&2 "[${ERR}] ${FUNC_SOURCE} - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # Collect input string.
    string="${@:-$(</dev/stdin)}"

    if [[ -z "${string}" ]]; then
        cat <<-EOF
	${FUNC_SOURCE} - urlencode stdin
	---
	string: \${@} (${@:-required})
	EOF
    else
       python -c $'try: import urllib.parse as urllib\nexcept: import urllib\nimport sys\nprint(urllib.quote(sys.argv[1]))' "${string}"
    fi
}

function urldecode()
{
    # Variable of where this function is being called from.
    FUNC_SOURCE="$(basename "${0}" 2> /dev/null)$([[ ! -z "${FUNCNAME[0]}" ]] && { echo "/${FUNCNAME[0]}"; })"

    # Verify function requirements
    for req in python; do
        type ${req} >/dev/null 2>&1 || {
            ERR="${?}"
            echo >&2 "[${ERR}] ${FUNC_SOURCE} - \"${req}\" is not installed or found. Aborting."
            exit ${ERR}
        }
    done

    # Collect input string.
    string="${@:-$(</dev/stdin)}"

    if [[ -z "${string}" ]]; then
        cat <<-EOF
	${FUNC_SOURCE} - urldecode stdin
	---
	string: \${@} (${@:-required})
	EOF
    else
        python -c $'try: import urllib.parse as urllib\nexcept: import urllib\nimport sys\nprint(urllib.unquote(sys.argv[1]))' "${string}"
    fi
}
