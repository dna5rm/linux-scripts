# This bash function is used for error reporting.  If an error occurs this function will include
# the line number of the error and a highlighted snippet of the code around the error.

function err_report() {
    cat <<-EOF
	# Error on line $1
	~~~bash
	$(grep -n -B3 -A3 ^"$(sed "${1}q;d" "${0}")"$ "${0}" | sed 's/[-:]/| /')
	~~~
	EOF
}

type glow >/dev/null 2>&1 && {
    trap 'err_report ${LINENO} | glow; exit ${?}' ERR
} || {
    trap 'echo; err_report ${LINENO}; exit ${?}' ERR
}
