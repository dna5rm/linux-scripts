function contains_element () {

    # read input
    [[ -t 0 ]] && {
        local args=( ${@:2} )
        local query=( ${1} )
    } || {
        local args=( ${@} )
        local query=( $(</dev/stdin) )
    }

    [[ -z "${args[@]}" ]] && {
        # Make sure here-doc EOF is tab indented!
        sed "s/^[ \t]*//" <<-EOF; return 2
        # ${FUNCNAME[0]}: Check if array contains element.

        ## Command Syntax
        > ArgIn: \`${FUNCNAME[0]} \${element} \${array}\`
        > StdIn: \`echo \${elements} | ${FUNCNAME[0]} \${array}\`

        | \$? | Exit Code Meaning       |
        | -- | --                      |
        |  0 | Contains element.       |
        |  1 | Does not have element.  |
        |  2 | Missing arguments.      |

	EOF
    } || {
        # loop query & unset i.
        local q && for q in ${query[@]}; do unset i
            # check against each args element.
            local e && for e in ${args[@]}; do
                # break if match or increment i.
                [[ "${e}" != "${q}" ]] && local i=$(( ${i:-0}+1 )) || break;
            done
            # return if i matches arg count.
            test "${#args[@]}" != "${i}" || return ${?}
        done
    }
}
