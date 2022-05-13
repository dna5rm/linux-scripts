### Bash Prompt ###
# MS Font: https://docs.microsoft.com/en-us/windows/terminal/cascadia-code
# Putty Apperance: Settings > Window > Appearance: Font = Cascadia Code PL SemiLight
# Putty Colors: Settings > Window > Colours: Allow all colour options
# Putty Terminal: Settings > Connection > Data: Terminal-type string = xterm-256color
#
# Color codes are for 8-bit ANSI: https://en.wikipedia.org/wiki/ANSI_escape_code

function set_prompt()
{
    # Set the PS1 configuration for the prompt
    local reset_color="\[\033[0m\]"
    local sep=$(printf "\ue0b0")
    local end="${reset_color}\]\n\$ "
    local start="\["

    # Variables used to configure the prompt
    if [[ ${UID} -eq 0 ]]; then
        local user="\[\e[38;5;1m\]\u${reset_color}"
    else
        local user="\u${reset_color}"
    fi

    # Underline host if connecting through SSH
    if [[ -n `is_remote` ]]; then
        local host="\e[4m\h\e[0m${reset_color}"
    else
        local host="\h${reset_color}"
    fi

    local path="\[\e[38;5;0m\]\[\e[48;5;4m\]${sep}\[\e[38;5;7m\]\e[1m \w/ ${reset_color}"

    # Build the prompt one piece at a time
    if [[ -n ${VIRTUAL_ENV} ]]; then
        local prompt="${start}(${VIRTUAL_ENV##/*/}) ${user}@${host} ${path}"
    else
        local prompt="${start}${user}@${host} ${path}"
    fi

    # Git repository status
    local git_status="`make_git_prompt`"
    if [[ -n ${git_status} ]]; then
        local prompt="${prompt}${git_status} ${reset_color}"
    fi

    local prompt="${prompt}${end}"

    PS1="${prompt}"
}

PROMPT_COMMAND=set_prompt

function is_remote()
{
    # See https://unix.stackexchange.com/questions/9605/how-can-i-detect-if-the-shell-is-controlled-from-ssh
    if [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_TTY}" ]]; then
        echo "true"
    else
        echo ""
    fi
}

function make_git_prompt()
{
    if inside_git_repo; then
        # Default values for the appearance of the prompt.
        local changed=$(printf "\u002b")   # "+"
        local staged=$(printf "\u2022")    # "•"
        local untracked=$(printf "\u003f") # "?"
        local conflict=$(printf "\u0078")  # "x"
        local ahead=$(printf "\u2191")     # "↑"
        local behind=$(printf "\u2193")    # "↓"
        local noremote=$(printf "\u2442")  # "⑂"
        local _sep="|"

        # Construct the status info (how many files changed, etc)
        local status=""

        local files_changed=`git diff --numstat | wc -l`

        if [[ ${files_changed} -ne 0 ]]; then
            if [[ -n ${status} ]]; then
                local status="${status}${_sep}"
            fi
            local status="${status}${changed}${files_changed}"
        fi

        local files_staged=`git diff --cached --numstat | wc -l`

        if [[ ${files_staged} -ne 0 ]]; then
            if [[ -n ${status} ]]; then
                local status="${status}${_sep}"
            fi
            local status="${status}${staged}${files_staged}"
        fi

        local files_conflict=`git diff --name-only --diff-filter=U | wc -l`

        if [[ ${files_conflict} -ne 0 ]]; then
            if [[ -n ${status} ]]; then
                local status="${status}${_sep}"
            fi
            local status="${status}${conflict}${files_conflict}"
        fi

        local files_untracked=`git ls-files --others --exclude-standard | wc -l`

        if [[ ${files_untracked} -ne 0 ]]; then
            if [[ -n ${status} ]]; then
                local status="${status}${_sep}"
            fi
            local status="${status}${untracked}${files_untracked}"
        fi

        local remote_status=`git rev-list --left-right --count @{u}...HEAD 2> /dev/null`
        local remote_behind=$(echo ${remote_status} | cut -f 1 -d " ")
        local remote_ahead=$(echo ${remote_status} | cut -f 2 -d " ")

        if [[ -z ${remote_status} ]]; then
            if [[ -n ${status} ]]; then
                local status="${status}${_sep}"
            fi
            local status="${status}${noremote}"
        fi

        if [[ ${remote_ahead} -gt 0 ]]; then
            if [[ -n ${status} ]]; then
                local status="${status}${_sep}"
            fi
            local status="${status}${ahead}${remote_ahead}"
        fi

        if [[ ${remote_behind} -gt 0 ]]; then
            if [[ -n ${status} ]]; then
                local status="${status}${_sep}"
            fi
            local status="${status}${behind}${remote_behind}"
        fi

        local branch=`get_git_branch`

        # Append the git info to the PS1
        local git_prompt="$(printf "\ue0a0")${branch}"
        if [[ -n ${status} ]]; then
            local git_prompt="\[\e[38;5;4m\]\[\e[48;5;11m\]${sep}\[\e[38;5;0m\] ${git_prompt}\[\e[38;5;8m\](${status}) \[\e[38;5;11m\]\[\e[48;5;0m\]${sep}"
        else
            local git_prompt="\[\e[38;5;4m\]\[\e[48;5;10m\]${sep}\[\e[38;5;0m\] ${git_prompt} \[\e[38;5;10m\]\[\e[48;5;0m\]${sep}"
        fi

        echo "${git_prompt}"
    else
        echo "\[\e[38;5;4m\]\[\e[48;5;0m\]${sep}"
    fi
}

function get_git_branch()
{
    # Get the name of the current git branch
    local branch=`git branch | grep "\* *" | sed -n -e "s/\* //p"`
    if [[ -z `echo ${branch} | grep "\(detached from *\)"` ]]; then
        echo ${branch}
    else
        # In case of detached head, get the commit hash
        echo ${branch} | sed -n -e "s/(detached from //p" | sed -n -e "s/)//p"
    fi
}

function inside_git_repo()
{
    # Test if inside a git repository. Will fail is not.
    git rev-parse --is-inside-work-tree 2> /dev/null > /dev/null
}
