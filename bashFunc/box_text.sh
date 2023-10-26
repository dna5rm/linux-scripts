function box_text ()
{
    # Verify function requirements
    for req in tput; do
        type ${req} >/dev/null 2>&1 || {
            [[ "${0}" != "-bash" ]] && {
                echo >&2 "$(basename "${0}"):${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            } || {
                echo >&2 "${FUNCNAME[0]} - cmd/function \"${req}\" is required!"
            }
            return 1
        }
    done

    # Contunue if no error code.
    [[ ${?} -eq 0 ]] && {
        # Print reference if conditions missing.
        if [[ -z "${1}" ]]; then
            # Skip basename if shell function
            [[ "${0}" != "-bash" ]] && {
                echo -n "$(basename "${0}"):"
            }
            echo "${FUNCNAME[0]} - Return a simple text box out of text."
            echo "Text: \${1} (${1:-required})" | sed 's/^[ \t]*//g'
        else
            local s=( "${@}" ) b w

            for l in "${s[@]}"; do
                (( w < ${#l} )) && {
                    b="${l}"
                    w="${#l}"
                }
            done

            tput setaf 3
            echo -en "+-${b//?/-}-+\n"

            for l in "${s[@]}"; do
                printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "${l}" "$(tput setaf 3)"
            done

            echo -en "+-${b//?/-}-+\n"
            tput sgr 0
        fi
    }
}
