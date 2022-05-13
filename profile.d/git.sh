# Git Functions
if command -v git &> /dev/null; then

    # Push to repo
    function git_push ()
    {
        # Print reference if conditions missing.
        if [[ -z "${1}" ]]; then
            # Skip basename if shell function
            [[ "${0}" != "-bash" ]] && {
                echo -n "$(basename "${0}"):"
            }
            echo "${FUNCNAME[0]} - Git add+commit+push to current branch."
            echo "Message: \${1} (${1:-requried})" | sed 's/^[ \t]*//g'
            echo
            git status 2> /dev/null
        else
            git add --all && git commit -m "${1:-update}" &&\
            git push -u origin `git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
        fi
    }

fi

